import 'package:dartz/dartz.dart';
// Si vous utilisez dartz pour la gestion des erreurs (recommandé)
import '../../entities/attendance_item.dart';
import '../../repositories/item_repository.dart';

// Définition d'une erreur simple pour l'exemple
class GetItemsFailure {}

class GetItems {
  final ItemRepository repository;

  GetItems(this.repository);

  // Exécute la lecture des critères
  // Utilise Either<Failure, Success> pour une gestion d'erreur propre
  Future<Either<GetItemsFailure, List<AttendanceItem>>> call(
    String spreadsheetId,
  ) async {
    try {
      final items = await repository.getItems(spreadsheetId);
      return Right(items); // Succès
    } catch (e) {
      // Pour l'instant, on enveloppe toutes les exceptions dans un échec générique
      return Left(GetItemsFailure()); // Échec
    }
  }
}
