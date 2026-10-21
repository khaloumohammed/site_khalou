// lib/presentation/home/google_sheet_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance_app/core/services/auth_service.dart';
import 'package:attendance_app/data/datasources/google_sheets_data_source.dart';
import 'package:attendance_app/core/services/eleves_service.dart';
import 'package:attendance_app/core/services/seances_service.dart';
import 'package:attendance_app/core/services/criteres_service.dart';
import 'package:attendance_app/presentation/home/google_sheet_state.dart';
import 'package:attendance_app/data/models/spreadsheet_info.dart';
import 'package:googleapis/sheets/v4.dart' as sheets_api;

/// Gère l'état de connexion aux feuilles Google Sheets
class GoogleSheetCubit extends Cubit<SheetState> {
  final GoogleSheetsDataSource _dataSource;
  final AuthService _authService;
  final ElevesService _elevesService;
  final SeancesService _seancesService;
  final CriteresService _criteresService;

  // Getters pour accès aux services depuis les écrans
  ElevesService get elevesService => _elevesService;
  SeancesService get seancesService => _seancesService;
  CriteresService get criteresService => _criteresService;

  // Compteurs
  int classCount = 0;
  int seancesCount = 0;
  int criteresCount = 0;

  SeancesState seancesState = const SeancesIdle();
  bool _isLoadingSheets = false;

  GoogleSheetCubit(
    this._dataSource,
    this._authService,
    this._elevesService,
    this._seancesService,
    this._criteresService,
  ) : super(const SheetInitial()) {
    checkInitialConnection();
  }

  /// Vérifie la connexion initiale lors du démarrage
  Future<void> checkInitialConnection() async {
    await loadAvailableSheets();
  }

  /// Obtient une instance de l'API Google Sheets
  Future<sheets_api.SheetsApi> getSheetsApi() => _dataSource.getSheetsApi();

  /// Obtient l'ID de la feuille de calcul actuellement connectée
  Future<String?> getSpreadsheetId() async {
    final currentState = state;
    if (currentState is SheetConnected) {
      return currentState.spreadsheetId;
    }
    return null;
  }

  /// Charge la liste des feuilles Google disponibles
  Future<void> loadAvailableSheets() async {
    // Évite les appels multiples simultanés
    if (_isLoadingSheets) return;

    _isLoadingSheets = true;
    emit(const SheetLoading());

    try {
      final sheets = await _dataSource.getSpreadsheets().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Timeout: Google Sheets indisponible'),
      );

      final correctedSheets = sheets
          .map((e) => SpreadsheetInfo(id: e.id, title: e.title))
          .toList();

      emit(SheetSelection(availableSheets: correctedSheets));
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Timeout')) {
        emit(
          const SheetError(
            'Délai d\'attente dépassé. Vérifiez votre connexion.',
          ),
        );
      } else {
        _handleLoadingError(e);
      }
    } finally {
      _isLoadingSheets = false;
    }
  }

  /// Gère les erreurs lors du chargement des feuilles
  void _handleLoadingError(Object error) {
    final errorMessage = error.toString();

    if (errorMessage.contains('authentifié') ||
        errorMessage.contains('Session expirée') ||
        errorMessage.contains('Session Google expirée')) {
      emit(
        const SheetError(
          'Session expirée. Veuillez vous reconnecter.',
          requiresReauthentication: true,
        ),
      );
    } else if (errorMessage.contains('401')) {
      emit(
        const SheetError(
          'Session Google expirée. Veuillez vous reconnecter.',
          requiresReauthentication: true,
        ),
      );
    } else if (errorMessage.contains('403') ||
        errorMessage.contains('Accès Google refusé')) {
      emit(
        const SheetError(
          'Google refuse l’accès à Drive ou Sheets pour ce compte. Vérifiez les autorisations accordées à l’application et l’accès à la feuille.',
        ),
      );
    } else {
      emit(SheetError('Erreur de chargement: $errorMessage'));
    }
  }

  /// Reconnecte l'utilisateur
  Future<void> reconnect() async {
    emit(const SheetLoading());

    try {
      final success = await _authService.signIn().timeout(
        const Duration(seconds: 60),
        onTimeout: () => false,
      );

      if (success) {
        await loadAvailableSheets();
      } else {
        emit(const SheetError('Échec de la reconnexion. Veuillez réessayer.'));
      }
    } catch (e) {
      emit(SheetError('Erreur reconnexion: ${e.toString()}'));
    }
  }

  /// Sélectionne une feuille de calcul
  void selectSheet(String id, String name) {
    _resetCounters();
    emit(SheetConnected(sheetId: id, sheetTitle: name, classCount: 0));
    _loadAllSheetData();
  }

  /// Déconnecte la feuille actuelle
  Future<void> disconnectSheet() async {
    _resetCounters();
    emit(const SheetDisconnected());
    await loadAvailableSheets();
  }

  /// Réinitialise tous les compteurs
  void _resetCounters() {
    classCount = 0;
    seancesCount = 0;
    criteresCount = 0;
    seancesState = const SeancesIdle();
  }

  /// Charge toutes les données après sélection d'une feuille
  Future<void> _loadAllSheetData() async {
    final currentState = state;
    if (currentState is! SheetConnected) return;

    await Future.wait([
      _loadClasses(),
      _loadSeances(),
      _loadCriteres(),
    ], eagerError: true);

    final updatedState = state;
    if (updatedState is SheetConnected) {
      emit(updatedState.copyWith(classCount: classCount));
    }
  }

  /// Charge les classes de la feuille
  Future<void> _loadClasses() async {
    final currentState = state;
    if (currentState is! SheetConnected) return;

    try {
      final classes = await _elevesService
          .getUniqueClasses(currentState.sheetId)
          .timeout(const Duration(seconds: 10), onTimeout: () => <String>[]);

      classCount = classes.length;
    } catch (e) {
      // Erreur silencieuse lors du chargement des classes
      classCount = 0;
    }
  }

  /// Charge les séances de la feuille
  Future<void> _loadSeances() async {
    final currentState = state;
    if (currentState is! SheetConnected) return;

    seancesState = const SeancesLoading();

    try {
      seancesCount = await _seancesService
          .getSeancesCount(currentState.sheetId)
          .timeout(const Duration(seconds: 10), onTimeout: () => 0);

      seancesState = SeancesSuccess(seancesCount);
    } catch (e) {
      // Erreur silencieuse lors du chargement des séances
      seancesCount = 0;
      seancesState = SeancesError(e.toString());
    }
  }

  /// Charge les critères de pointage de la feuille
  Future<void> _loadCriteres() async {
    final currentState = state;
    if (currentState is! SheetConnected) return;

    try {
      final criteres = await _criteresService.getCriteres(currentState.sheetId);
      criteresCount = criteres.length;
    } catch (e) {
      // Erreur silencieuse lors du chargement des critères
      criteresCount = 0;
    }
  }

  /// Récupère les classes avec le nombre d'élèves par classe
  Future<Map<String, int>> getClassesWithStudentCount() async {
    final currentState = state;
    if (currentState is! SheetConnected) return {};

    try {
      final classes = await _elevesService.getUniqueClasses(
        currentState.sheetId,
      );
      final studentCountByClass = <String, int>{};

      for (final className in classes) {
        try {
          final eleves = await _elevesService.getElevesByClasse(
            currentState.sheetId,
            className,
          );
          studentCountByClass[className] = eleves.length;
        } catch (e) {
          // Erreur silencieuse lors du comptage des élèves
          studentCountByClass[className] = 0;
        }
      }

      return studentCountByClass;
    } catch (e) {
      // Erreur silencieuse lors de la récupération des classes
      return {};
    }
  }
}
