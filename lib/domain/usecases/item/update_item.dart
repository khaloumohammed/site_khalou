import 'package:dartz/dartz.dart';
import '../../repositories/item_repository.dart';

// Définition d'une erreur simple pour l'exemple
class UpdateItemFailure {}

class UpdateItem {
  final ItemRepository repository;

  UpdateItem(this.repository);

  // Exécute la mise à jour d'un critère
  // Utilise Either<Failure, Success> pour une gestion d'erreur propre
  Future<Either<UpdateItemFailure, void>> call(
    String spreadsheetId,
    String oldCritere,
    String newCritere,
  ) async {
    try {
      await repository.updateItem(spreadsheetId, oldCritere, newCritere);
      return Right(null); // Succès
    } catch (e) {
      // Pour l'instant, on enveloppe toutes les exceptions dans un échec générique
      return Left(UpdateItemFailure()); // Échec
    }
  }
}
