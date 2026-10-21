import 'package:dartz/dartz.dart';
import 'package:attendance_app/domain/repositories/eleve_repository.dart';

// Définition d'une erreur simple pour l'exemple
class UpdateEleveFailure {
  final String message;
  UpdateEleveFailure([this.message = "Erreur lors de la modification"]);

  @override
  String toString() => message;
}

class UpdateEleve {
  final EleveRepository repository;

  UpdateEleve(this.repository);

  // Exécute la mise à jour d'un élève
  // Utilise Either<Failure, Success> pour une gestion d'erreur propre
  Future<Either<UpdateEleveFailure, void>> call(
    String spreadsheetId,
    String id,
    Map<String, String> data,
  ) async {
    try {
      // 1) Récupérer la liste des élèves existants
      final eleves = await repository.getEleves(spreadsheetId);

      // 2) Retrouver l'élève courant
      final currentEleve = eleves.any((e) => e.id == id)
          ? eleves.firstWhere((e) => e.id == id)
          : null;

      // 3) Calculer le nouvel id (si numero/classe changent)
      final numero = data['numero']?.trim() ?? currentEleve?.numero ?? '';
      final classe = data['classe']?.trim() ?? currentEleve?.classe ?? '';
      final newId = "${numero}_$classe";

      // 4) Vérifier si un autre élève a déjà ce même id
      final hasDuplicate = eleves.any((e) => e.id != id && e.id == newId);

      if (hasDuplicate) {
        // doublon détecté → on renvoie une erreur propre
        return Left(UpdateEleveFailure());
      }

      // 5) Mise à jour avec l'id recalculé
      final enrichedData = {...data, 'id': newId};

      await repository.updateEleveMethod(spreadsheetId, id, enrichedData);
      return Right(null); // Succès
    } catch (e) {
      return Left(UpdateEleveFailure()); // Échec
    }
  }
}
