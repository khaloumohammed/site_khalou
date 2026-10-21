import 'package:dartz/dartz.dart';
import '../../repositories/item_repository.dart';

// Définition d'une erreur simple pour l'exemple
class DeleteItemFailure {}

class DeleteItem {
  final ItemRepository repository;

  DeleteItem(this.repository);

  // Exécute la suppression d'un critère
  // Utilise Either<Failure, Success> pour une gestion d'erreur propre
  Future<Either<DeleteItemFailure, void>> call(
    String spreadsheetId,
    String critereToDelete,
  ) async {
    try {
      await repository.deleteItem(spreadsheetId, critereToDelete);
      return Right(null); // Succès
    } catch (e) {
      // Pour l'instant, on enveloppe toutes les exceptions dans un échec générique
      return Left(DeleteItemFailure()); // Échec
    }
  }
}
