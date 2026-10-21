class AttendanceItem {
  final int id;
  final String critere;

  const AttendanceItem({required this.id, required this.critere});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          critere == other.critere;

  @override
  int get hashCode => id.hashCode ^ critere.hashCode;
}
