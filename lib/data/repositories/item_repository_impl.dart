import '../../core/services/criteres_service.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/entities/attendance_item.dart';

/// Implémentation de ItemRepository basée sur Google Sheets
class ItemRepositoryImpl implements ItemRepository {
  final CriteresService _criteresService;

  ItemRepositoryImpl(this._criteresService);

  @override
  Future<List<AttendanceItem>> getItems(String spreadsheetId) async {
    try {
      final criteresData = await _criteresService.getCriteres(spreadsheetId);

      final items = criteresData
          .map((data) {
            final id = int.tryParse(data['id'] ?? '') ?? 0;
            final critere = data['critere']?.trim() ?? '';

            return AttendanceItem(id: id, critere: critere);
          })
          .where((item) => item.critere.isNotEmpty)
          .toList();

      return items;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createItem(String spreadsheetId, String newCritere) async {
    try {
      await _criteresService.createCritere(spreadsheetId, newCritere);
    } catch (e) {
      throw Exception(
        "Erreur lors de la création du critère '$newCritere': $e",
      );
    }
  }

  @override
  Future<void> updateItem(
    String spreadsheetId,
    String oldCritere,
    String newCritere,
  ) async {
    try {
      // Supprimer l'ancien critère
      await _criteresService.deleteCritere(spreadsheetId, oldCritere);
      // Ajouter le nouveau critère
      await _criteresService.createCritere(spreadsheetId, newCritere);
    } catch (e) {
      throw Exception(
        "Erreur lors de la mise à jour du critère '$oldCritere' → '$newCritere': $e",
      );
    }
  }

  @override
  Future<void> deleteItem(String spreadsheetId, String critereToDelete) async {
    try {
      await _criteresService.deleteCritere(spreadsheetId, critereToDelete);
    } catch (e) {
      throw Exception(
        "Erreur lors de la suppression du critère '$critereToDelete': $e",
      );
    }
  }
}
