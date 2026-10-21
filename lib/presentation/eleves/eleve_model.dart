class Eleve {
  final String numero; // N° de l'élève (peut être "1", "2", etc.)
  final String nom; // Nom de l'élève
  final String classe; // Classe (ex: "TCSF-1")
  final String genre; // Genre: "G" ou "F"
  final String naissance; // Année de naissance (ex: "2010")
  final String id; // ID unique (ex: "TCSF-1_1")

  Eleve({
    required this.numero,
    required this.nom,
    required this.classe,
    required this.genre,
    required this.naissance,
    required this.id,
  });

  /// Crée un Eleve depuis une ligne de Google Sheets
  /// Format attendu: [N°, Nom, Classe, Genre, Naissance, ID_Elève]
  factory Eleve.fromSheet(List<dynamic> row) {
    return Eleve(
      numero: row.isNotEmpty && row[0] != null ? row[0].toString() : '0',
      nom: row.length > 1 && row[1] != null ? row[1].toString() : '',
      classe: row.length > 2 && row[2] != null ? row[2].toString() : '',
      genre: row.length > 3 && row[3] != null
          ? row[3].toString().toUpperCase()
          : 'G',
      naissance: row.length > 4 && row[4] != null ? row[4].toString() : '',
      id: row.length > 5 && row[5] != null ? row[5].toString() : '',
    );
  }

  /// Crée un Eleve depuis un Map (depuis le service)
  factory Eleve.fromMap(Map<String, dynamic> data) {
    return Eleve(
      numero: data['N°']?.toString() ?? '0',
      nom: data['Nom']?.toString() ?? '',
      classe: data['Classe']?.toString() ?? '',
      genre: data['Genre']?.toString().toUpperCase() ?? 'G',
      naissance:
          data['Naissance']?.toString() ?? data['Naissanc']?.toString() ?? '',
      id: data['ID_Elève']?.toString() ?? data['ID_Élève']?.toString() ?? '',
    );
  }

  /// Convertit l'objet en liste pour Google Sheets
  List<String> toSheetRow() {
    return [numero, nom, classe, genre, naissance, id];
  }

  /// Convertit l'objet en Map
  Map<String, dynamic> toMap() {
    return {
      'N°': numero,
      'Nom': nom,
      'Classe': classe,
      'Genre': genre,
      'Naissance': naissance,
      'ID_Elève': id,
    };
  }

  /// Convertit l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'nom': nom,
      'classe': classe,
      'genre': genre,
      'naissance': naissance,
      'id': id,
    };
  }

  /// Crée un Eleve depuis JSON
  factory Eleve.fromJson(Map<String, dynamic> json) {
    return Eleve(
      numero: json['numero']?.toString() ?? '0',
      nom: json['nom']?.toString() ?? '',
      classe: json['classe']?.toString() ?? '',
      genre: json['genre']?.toString().toUpperCase() ?? 'G',
      naissance: json['naissance']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
    );
  }

  /// Calcule l'âge de l'élève
  int get age {
    final year = int.tryParse(naissance) ?? DateTime.now().year;
    return DateTime.now().year - year;
  }

  /// Obtient le numéro en tant qu'entier
  int get numeroInt {
    return int.tryParse(numero) ?? 0;
  }

  /// Vérifie si l'élève est une fille
  bool get isFemale => genre.toUpperCase() == 'F';

  /// Vérifie si l'élève est un garçon
  bool get isMale => genre.toUpperCase() == 'G' || genre.toUpperCase() == 'M';

  /// Crée une copie de l'objet avec des modifications
  Eleve copyWith({
    String? numero,
    String? nom,
    String? classe,
    String? genre,
    String? naissance,
    String? id,
  }) {
    return Eleve(
      numero: numero ?? this.numero,
      nom: nom ?? this.nom,
      classe: classe ?? this.classe,
      genre: genre ?? this.genre,
      naissance: naissance ?? this.naissance,
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    return 'Eleve(numero: $numero, nom: $nom, classe: $classe, genre: $genre, naissance: $naissance, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Eleve &&
        other.numero == numero &&
        other.nom == nom &&
        other.classe == classe &&
        other.genre == genre &&
        other.naissance == naissance &&
        other.id == id;
  }

  @override
  int get hashCode {
    return numero.hashCode ^
        nom.hashCode ^
        classe.hashCode ^
        genre.hashCode ^
        naissance.hashCode ^
        id.hashCode;
  }
}
