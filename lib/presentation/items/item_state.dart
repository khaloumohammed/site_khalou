import '../../domain/entities/attendance_item.dart';

abstract class ItemState {
  const ItemState();
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemLoaded extends ItemState {
  final List<AttendanceItem> items;
  const ItemLoaded(this.items);
}

class ItemError extends ItemState {
  final String message;
  const ItemError(this.message);
}
