import '../../domain/entities/attendance_eleve.dart';

abstract class ElevesState {
  const ElevesState();
}

class ElevesInitial extends ElevesState {
  const ElevesInitial();
}

class ElevesLoading extends ElevesState {
  const ElevesLoading();
}

class ElevesLoaded extends ElevesState {
  final List<AttendanceEleve> eleves;
  const ElevesLoaded(this.eleves);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElevesLoaded && _listEquals(other.eleves, eleves);
  }

  @override
  int get hashCode => eleves.hashCode;
}

class ElevesOperationLoading extends ElevesState {
  final List<AttendanceEleve> currentEleves;
  const ElevesOperationLoading(this.currentEleves);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElevesOperationLoading &&
        _listEquals(other.currentEleves, currentEleves);
  }

  @override
  int get hashCode => currentEleves.hashCode;
}

class ElevesOperationSuccess extends ElevesState {
  final String message;
  const ElevesOperationSuccess(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElevesOperationSuccess && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class ElevesError extends ElevesState {
  final String message;
  const ElevesError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElevesError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

// Helper function for deep list comparison
bool _listEquals<T>(List<T>? list1, List<T>? list2) {
  if (identical(list1, list2)) return true;
  if (list1 == null || list2 == null) return false;
  if (list1.length != list2.length) return false;

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }

  return true;
}
