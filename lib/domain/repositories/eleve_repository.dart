import 'package:attendance_app/domain/entities/attendance_eleve.dart';
import 'package:attendance_app/presentation/eleves/eleve_model.dart';

abstract class EleveRepository {
  Future<List<AttendanceEleve>> getEleves(String spreadsheetId);
  Future<void> createEleveMethod(
    String spreadsheetId,
    Map<String, String> data,
  );
  Future<void> updateEleveMethod(
    String spreadsheetId,
    String id,
    Map<String, String> data,
  );
  Future<void> deleteEleveMethod(String spreadsheetId, String id);
  Future<void> updateNumerosBatch(
    String spreadsheetId,
    Map<String, String> numerosParId,
  );

  /// Récupère la liste des élèves d'une classe spécifique
  Future<List<Eleve>> getElevesByClasse(String spreadsheetId, String classe);
}
