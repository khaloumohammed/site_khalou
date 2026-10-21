class AttendanceEleve {
  final String numero;
  final String nom;
  final String classe;
  final String genre;
  final String naissance;
  final String age;
  final String id;

  const AttendanceEleve({
    required this.numero,
    required this.nom,
    required this.classe,
    required this.genre,
    required this.naissance,
    required this.age,
    required this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceEleve &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nom == other.nom &&
          numero == other.numero &&
          classe == other.classe &&
          genre == other.genre &&
          naissance == other.naissance &&
          age == other.age;

  @override
  int get hashCode =>
      id.hashCode ^
      nom.hashCode ^
      numero.hashCode ^
      classe.hashCode ^
      genre.hashCode ^
      naissance.hashCode ^
      age.hashCode;
}
