import 'package:dartz/dartz.dart';
import 'package:attendance_app/domain/entities/attendance_eleve.dart';
import 'package:attendance_app/domain/repositories/eleve_repository.dart';

// Définition d'une erreur simple pour l'exemple
class GetElevesFailure {}

class GetEleves {
  final EleveRepository repository;

  GetEleves(this.repository);

  // Exécute la lecture des élèves
  // Utilise Either<Failure, Success> pour une gestion d'erreur propre
  Future<Either<GetElevesFailure, List<AttendanceEleve>>> call(
    String spreadsheetId,
  ) async {
    try {
      final eleves = await repository.getEleves(spreadsheetId);
      return Right(eleves); // Succès
    } catch (e) {
      return Left(GetElevesFailure()); // Échec
    }
  }
}
