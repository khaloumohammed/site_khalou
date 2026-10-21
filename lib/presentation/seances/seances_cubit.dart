// lib/presentation/seances/seances_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance_app/presentation/seances/seances_state.dart';
import 'package:attendance_app/data/models/seance_model.dart';
import 'package:attendance_app/core/services/seances_service.dart';

/// Gère l'état des séances
class SessionCubit extends Cubit<SessionState> {
  final SeancesService _seancesService;

  List<SeanceModel> _seances = [];
  String? _spreadsheetId;

  SessionCubit({required SeancesService seancesService})
    : _seancesService = seancesService,
      super(SessionInitial());

  /// Définit le spreadsheetId et charge les séances
  void setSpreadsheetId(String spreadsheetId) {
    _spreadsheetId = spreadsheetId;
    loadSeances(spreadsheetId);
  }

  /// Charge les séances depuis Google Sheets
  Future<void> loadSeances(String spreadsheetId) async {
    emit(SessionLoading());

    try {
      _spreadsheetId = spreadsheetId;

      final seancesData = await _seancesService.getSeances(spreadsheetId);

      _seances = seancesData.map((data) {
        final uniqueId = '${data['jour']}_${data['horaire']}_${data['classe']}'
            .replaceAll(' ', '_')
            .replaceAll('-', '_')
            .replaceAll(':', '_');

        return SeanceModel(
          id: uniqueId,
          jour: data['jour'] ?? '',
          horaire: data['horaire'] ?? '',
          classe: data['classe'] ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      emit(SessionLoaded(_seances));
    } catch (e) {
      emit(SessionError('Erreur de chargement: ${e.toString()}'));
    }
  }

  /// Récupère une séance par son ID
  SeanceModel? getSeanceById(String seanceId) {
    try {
      return _seances.firstWhere((s) => s.id == seanceId);
    } catch (_) {
      return null;
    }
  }

  /// Affiche toutes les séances (annule tout filtrage)
  void showAllSeances() {
    emit(SessionLoaded(_seances));
  }

  /// Filtre par jour exact
  void filterByExactDay(String jour) {
    if (jour.trim().isEmpty) {
      emit(SessionLoaded(_seances));
      return;
    }

    final filtered = _seances
        .where((s) => s.jour.toLowerCase() == jour.toLowerCase())
        .toList();

    emit(SessionLoaded(filtered));
  }

  /// Recherche dans tous les champs
  void searchSeances(String query) {
    if (query.trim().isEmpty) {
      emit(SessionLoaded(_seances));
      return;
    }

    final queryLower = query.toLowerCase();
    final filtered = _seances
        .where(
          (s) =>
              s.jour.toLowerCase().contains(queryLower) ||
              s.horaire.toLowerCase().contains(queryLower) ||
              s.classe.toLowerCase().contains(queryLower),
        )
        .toList();

    emit(SessionLoaded(filtered));
  }

  /// Ajoute une nouvelle séance
  Future<void> addSeance({
    required String jour,
    required String horaire,
    required String classe,
  }) async {
    try {
      if (_spreadsheetId == null) {
        emit(SessionError('Aucune feuille connectée'));
        return;
      }

      await _seancesService.createSeance(
        spreadsheetId: _spreadsheetId!,
        jour: jour,
        horaire: horaire,
        classe: classe,
      );

      await loadSeances(_spreadsheetId!);
    } catch (e) {
      emit(SessionError('Erreur ajout: ${e.toString()}'));
    }
  }

  /// Modifie une séance existante
  Future<void> updateSeance(
    String seanceId, {
    String? jour,
    String? horaire,
    String? classe,
  }) async {
    try {
      if (_spreadsheetId == null) {
        emit(SessionError('Aucune feuille connectée'));
        return;
      }

      final currentSeance = getSeanceById(seanceId);
      if (currentSeance == null) {
        emit(SessionError('Séance non trouvée'));
        return;
      }

      await _seancesService.updateSeance(
        spreadsheetId: _spreadsheetId!,
        oldJour: currentSeance.jour,
        oldHoraire: currentSeance.horaire,
        oldClasse: currentSeance.classe,
        newJour: jour ?? currentSeance.jour,
        newHoraire: horaire ?? currentSeance.horaire,
        newClasse: classe ?? currentSeance.classe,
      );

      await loadSeances(_spreadsheetId!);
    } catch (e) {
      emit(SessionError('Erreur modification: ${e.toString()}'));
    }
  }

  /// Supprime une séance
  Future<void> deleteSeance(String seanceId) async {
    try {
      if (_spreadsheetId == null) {
        emit(SessionError('Aucune feuille connectée'));
        return;
      }

      final currentSeance = getSeanceById(seanceId);
      if (currentSeance == null) {
        emit(SessionError('Séance non trouvée'));
        return;
      }

      await _seancesService.deleteSeance(
        spreadsheetId: _spreadsheetId!,
        jour: currentSeance.jour,
        horaire: currentSeance.horaire,
        classe: currentSeance.classe,
      );

      await loadSeances(_spreadsheetId!);
    } catch (e) {
      emit(SessionError('Erreur suppression: ${e.toString()}'));
    }
  }

  /// Récupère les séances d'une classe spécifique
  List<SeanceModel> getSeancesByClass(String classe) {
    return _seances.where((s) => s.classe == classe).toList();
  }

  /// Récupère les séances d'un jour spécifique
  List<SeanceModel> getSeancesByDay(String jour) {
    return _seances.where((s) => s.jour == jour).toList();
  }

  /// Récupère les statistiques des séances
  Map<String, int> getSeancesStatistics() {
    final stats = <String, int>{};

    // Groupement par classe
    final classes = _seances.map((s) => s.classe).toSet();
    for (final classe in classes) {
      stats['classe_$classe'] = _seances
          .where((s) => s.classe == classe)
          .length;
    }

    // Groupement par jour
    final jours = _seances.map((s) => s.jour).toSet();
    for (final jour in jours) {
      stats['jour_$jour'] = _seances.where((s) => s.jour == jour).length;
    }

    stats['total'] = _seances.length;
    stats['classes_count'] = classes.length;
    stats['jours_count'] = jours.length;

    return stats;
  }
}
