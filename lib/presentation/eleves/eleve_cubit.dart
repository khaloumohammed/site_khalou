import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/domain/entities/attendance_eleve.dart';
import 'package:attendance_app/domain/usecases/eleve/get_eleves.dart';
import 'package:attendance_app/domain/usecases/eleve/create_eleve.dart';
import 'package:attendance_app/domain/usecases/eleve/update_eleve.dart';
import 'package:attendance_app/domain/usecases/eleve/delete_eleve.dart';
import 'package:attendance_app/domain/usecases/eleve/update_numeros_en_masse.dart';

import 'eleve_state.dart';

class ElevesCubit extends Cubit<ElevesState> {
  final GetEleves getElevesUsecase;
  final CreateEleve createEleveUsecase;
  final UpdateEleve updateEleveUsecase;
  final DeleteEleve deleteEleveUsecase;
  final UpdateNumerosEnMasse updateNumerosUsecase;

  ElevesCubit({
    required this.getElevesUsecase,
    required this.createEleveUsecase,
    required this.updateEleveUsecase,
    required this.deleteEleveUsecase,
    required this.updateNumerosUsecase,
  }) : super(const ElevesInitial());

  /// Modification en masse des N° : valide l'unicité à la fin, puis écrit en une fois.
  /// Retourne null si succès, sinon le message d'erreur détaillé.
  Future<String?> updateNumerosEnMasse(
    String sheetId,
    String classe,
    List<AttendanceEleve> elevesClasse,
    Map<String, String> nouveauxNumeros,
  ) async {
    final erreur = await updateNumerosUsecase(
      sheetId,
      classe,
      elevesClasse,
      nouveauxNumeros,
    );
    if (erreur != null) return erreur;
    emit(const ElevesOperationSuccess('N° modifiés avec succès'));
    // Le rechargement (qui bascule tout le corps de l'écran entre un
    // indicateur de chargement et la liste) n'est volontairement PAS attendu
    // ici : on le déclenche après coup pour qu'il ne se produise pas pendant
    // que le dialogue de modification en masse est encore ouvert/en train de
    // se fermer. Faire les deux en même temps (fermeture de route + gros
    // remplacement d'arbre de widgets) provoquait un crash Flutter
    // (`_dependents.isEmpty`).
    unawaited(fetchEleves(sheetId));
    return null;
  }

  /// Charger la liste des élèves
  Future<void> fetchEleves(String sheetId) async {
    emit(const ElevesLoading());
    try {
      final result = await getElevesUsecase(sheetId);

      result.fold(
        (failure) {
          emit(ElevesError("Erreur lors du chargement: $failure"));
        },
        (eleves) {
          emit(ElevesLoaded(eleves));
        },
      );
    } catch (e) {
      emit(ElevesError("Exception: $e"));
    }
  }

  /// Créer un élève
  /// Les données doivent contenir: id, numero, nom, classe, genre, naissance
  /// L'ID doit être au format: numero_classe
  Future<void> createEleveMethod(
    String sheetId,
    Map<String, String> data,
  ) async {
    final currentState = state;
    if (currentState is ElevesLoaded) {
      emit(ElevesOperationLoading(currentState.eleves));
    }

    try {
      // Validation que l'ID est fourni
      if (!data.containsKey('id') || data['id']!.trim().isEmpty) {
        emit(const ElevesError("Erreur: L'ID de l'élève est requis"));
        return;
      }

      // Validation du format de l'ID
      final id = data['id']!;
      final numero = data['numero'] ?? '';
      final classe = data['classe'] ?? '';
      final expectedId = "${classe}_$numero"; // Format: classe_numero

      if (id != expectedId) {
        // On corrige automatiquement
        data = {...data, 'id': expectedId};
      }

      // Appel du use case
      final result = await createEleveUsecase(sheetId, data);

      result.fold(
        (failure) {
          emit(ElevesError("Erreur lors de la création: ${failure.message}"));
        },
        (_) {
          emit(const ElevesOperationSuccess("Élève ajouté avec succès"));
          fetchEleves(sheetId);
        },
      );
    } catch (e) {
      emit(ElevesError("Erreur lors de la création: $e"));
    }
  }

  /// Mettre à jour un élève
  /// ATTENTION: Si le numero ou la classe change, l'ID devra être recalculé
  Future<void> updateEleveMethod(
    String sheetId,
    String id,
    Map<String, String> data,
  ) async {
    final currentState = state;
    if (currentState is ElevesLoaded) {
      emit(ElevesOperationLoading(currentState.eleves));
    }

    try {
      // Vérification si numero ou classe changent
      if (data.containsKey('numero') || data.containsKey('classe')) {
        // Récupérer l'élève actuel pour avoir les valeurs complètes
        if (currentState is ElevesLoaded) {
          final currentEleve = currentState.eleves.firstWhere(
            (e) => e.id == id,
            orElse: () => throw Exception("Élève non trouvé"),
          );

          final newNumero = data['numero'] ?? currentEleve.numero;
          final newClasse = data['classe'] ?? currentEleve.classe;
          final newId = "${newClasse}_$newNumero"; // Format: classe_numero

          if (newId != id) {
            // Pour l'instant, on laisse le service gérer cette logique
          }
        }
      }

      final result = await updateEleveUsecase(sheetId, id, data);

      result.fold(
        (failure) {
          emit(
            ElevesError("Erreur lors de la mise à jour: ${failure.message}"),
          );
        },
        (_) {
          emit(const ElevesOperationSuccess("Élève modifié avec succès"));
          fetchEleves(sheetId);
        },
      );
    } catch (e) {
      emit(ElevesError("Erreur lors de la mise à jour: $e"));
    }
  }

  /// Supprimer un élève
  Future<void> deleteEleveMethod(String sheetId, String id) async {
    final currentState = state;
    if (currentState is ElevesLoaded) {
      emit(ElevesOperationLoading(currentState.eleves));
    }

    try {
      final result = await deleteEleveUsecase(sheetId, id);

      result.fold(
        (failure) {
          emit(
            ElevesError("Erreur lors de la suppression: ${failure.message}"),
          );
        },
        (_) {
          emit(const ElevesOperationSuccess("Élève supprimé avec succès"));
          fetchEleves(sheetId);
        },
      );
    } catch (e) {
      emit(ElevesError("Erreur lors de la suppression: $e"));
    }
  }

  /// Méthode utilitaire pour générer un ID d'élève
  /// Format standard: classe_numero
  static String generateEleveId(String classe, String numero) {
    return "${classe.trim()}_${numero.trim()}";
  }
}
