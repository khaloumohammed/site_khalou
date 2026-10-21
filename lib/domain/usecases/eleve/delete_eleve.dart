import 'package:dartz/dartz.dart';
import 'package:attendance_app/domain/repositories/eleve_repository.dart';

// Définition d'une erreur simple pour l'exemple
class DeleteEleveFailure {
  final String message;
  DeleteEleveFailure([
    this.message = "Erreur lors de la suppression de l'élève",
  ]);

  @override
  String toString() => message;
}

class DeleteEleve {
  final EleveRepository repository;

  DeleteEleve(this.repository);

  // Exécute la suppression d'un élève
  // Utilise Either<Failure, Success> pour une gestion d'erreur propre
  Future<Either<DeleteEleveFailure, void>> call(
    String spreadsheetId,
    String id,
  ) async {
    try {
      await repository.deleteEleveMethod(spreadsheetId, id);
      return Right(null); // Succès
    } catch (e) {
      return Left(DeleteEleveFailure()); // Échec
    }
  }
}
