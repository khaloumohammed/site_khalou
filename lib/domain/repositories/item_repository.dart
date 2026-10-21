import '../entities/attendance_item.dart';

abstract class ItemRepository {
  Future<List<AttendanceItem>> getItems(String spreadsheetId);
  Future<void> createItem(String spreadsheetId, String newCritere);
  Future<void> updateItem(
    String spreadsheetId,
    String oldCritere,
    String newCritere,
  );
  Future<void> deleteItem(String spreadsheetId, String critereToDelete);
}
