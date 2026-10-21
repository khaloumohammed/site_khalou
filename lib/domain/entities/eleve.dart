class Eleve {
  final String id;
  final String nom;
  final String prenom;
  final String classe;
  final String genre;

  Eleve({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.classe,
    this.genre = 'g', // Par défaut à 'g' (garçon) si non spécifié
  });

  // Créer un Eleve à partir d'une ligne de Google Sheets
  factory Eleve.fromJson(Map<String, dynamic> json) {
    return Eleve(
      id: json['ID'] ?? '',
      nom: json['Nom'] ?? '',
      prenom: json['Prénom'] ?? '',
      classe: json['Classe'] ?? '',
      genre: (json['Genre'] ?? 'g').toString().toLowerCase(),
    );
  }

  // Propriété calculée pour le nom complet
  String get nomComplet => '$prenom $nom';
}
