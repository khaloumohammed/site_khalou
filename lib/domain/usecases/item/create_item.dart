import 'package:dartz/dartz.dart';
import '../../repositories/item_repository.dart';

// Définition d'une erreur simple pour l'exemple
class CreateItemFailure {}

class CreateItem {
  final ItemRepository repository;

  CreateItem(this.repository);

  // Exécute la création d'un critère
  // Utilise Either<Failure, Success> pour une gestion d'erreur propre
  Future<Either<CreateItemFailure, void>> call(
    String spreadsheetId,
    String critere,
  ) async {
    try {
      await repository.createItem(spreadsheetId, critere);
      return Right(null); // Succès
    } catch (e) {
      // Pour l'instant, on enveloppe toutes les exceptions dans un échec générique
      return Left(CreateItemFailure()); // Échec
    }
  }
}
