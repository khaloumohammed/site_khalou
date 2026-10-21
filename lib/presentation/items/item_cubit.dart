import 'package:flutter_bloc/flutter_bloc.dart';
import 'item_state.dart';
import '../../domain/usecases/item/get_items.dart';
import '../../domain/usecases/item/create_item.dart';
import '../../domain/usecases/item/update_item.dart';
import '../../domain/usecases/item/delete_item.dart';

class ItemCubit extends Cubit<ItemState> {
  final GetItems getItems;
  final CreateItem createItem;
  final UpdateItem updateItem;
  final DeleteItem deleteItem;
  ItemCubit({
    required this.getItems,
    required this.createItem,
    required this.updateItem,
    required this.deleteItem,
  }) : super(ItemInitial());

  Future<void> fetchItems(String spreadsheetId) async {
    emit(ItemLoading());

    try {
      final result = await getItems.call(spreadsheetId);

      result.fold(
        (failure) => emit(ItemError('Erreur lors du chargement des critères.')),
        (items) => emit(ItemLoaded(items)),
      );
    } catch (e) {
      emit(
        ItemError('Erreur lors du chargement des critères: ${e.toString()}'),
      );
    }
  }

  Future<void> _reloadItems(String spreadsheetId) async {
    try {
      final result = await getItems.call(spreadsheetId);
      result.fold(
        (failure) =>
            emit(ItemError('Erreur lors du rechargement des critères.')),
        (items) => emit(ItemLoaded(items)),
      );
    } catch (e) {
      emit(ItemError('Erreur lors du rechargement: ${e.toString()}'));
    }
  }

  Future<void> addItem(String spreadsheetId, String critere) async {
    try {
      final result = await createItem.call(spreadsheetId, critere);

      result.fold(
        (failure) => emit(ItemError('Erreur lors de l\'ajout du critère.')),
        (_) async {
          await _reloadItems(spreadsheetId);
        },
      );
    } catch (e) {
      emit(ItemError('Erreur lors de l\'ajout du critère: ${e.toString()}'));
    }
  }

  Future<void> updateItemMethod(
    String spreadsheetId,
    String oldCritere,
    String newCritere,
  ) async {
    try {
      final result = await updateItem.call(
        spreadsheetId,
        oldCritere,
        newCritere,
      );

      result.fold(
        (failure) =>
            emit(ItemError('Erreur lors de la modification du critère.')),
        (_) async {
          await _reloadItems(spreadsheetId);
        },
      );
    } catch (e) {
      emit(
        ItemError('Erreur lors de la modification du critère: ${e.toString()}'),
      );
    }
  }

  Future<void> deleteItemMethod(
    String spreadsheetId,
    String critereToDelete,
  ) async {
    try {
      final result = await deleteItem.call(spreadsheetId, critereToDelete);

      result.fold(
        (failure) =>
            emit(ItemError('Erreur lors de la suppression du critère.')),
        (_) async {
          await _reloadItems(spreadsheetId);
        },
      );
    } catch (e) {
      emit(
        ItemError('Erreur lors de la suppression du critère: ${e.toString()}'),
      );
    }
  }
}
