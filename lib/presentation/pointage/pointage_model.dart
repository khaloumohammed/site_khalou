import 'package:intl/intl.dart';

/// Modèle pour les pointages enregistrés dans l'onglet "Pointage" de Google Sheets
/// Structure: N°-Nom-Classe-Jour-Horaire-Date-Statut-ID_Elève
class PointageModel {
  final String numero; // Numéro de l'élève dans sa classe
  final String nomEleve;
  final String classe;
  final String jour;
  final String horaire;
  final DateTime date;
  final String statut; // Critère ou "Présent"
  final String idEleve;

  PointageModel({
    required this.numero,
    required this.nomEleve,
    required this.classe,
    required this.jour,
    required this.horaire,
    required this.date,
    required this.statut,
    required this.idEleve,
  });

  /// Crée une liste d'objets PointageModel à partir d'un élève et de ses critères
  /// Un objet par critère sélectionné
  static List<PointageModel> fromEleveAndCriteres({
    required int numeroEleve,
    required String nomEleve,
    required String classe,
    required String jour,
    required String horaire,
    required String date,
    required String heure,
    required List<String> statuts,
    required String idEleve,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    // Créer un DateTime à partir de la date et de l'heure
    DateTime dateTime;
    try {
      final datePart = dateFormat.parse(date);
      final timePart = timeFormat.parse(heure);
      dateTime = DateTime(
        datePart.year,
        datePart.month,
        datePart.day,
        timePart.hour,
        timePart.minute,
      );
    } catch (e) {
      // En cas d'erreur de parsing, utiliser la date et l'heure actuelles
      dateTime = DateTime.now();
    }

    // Si aucun critère n'est sélectionné, créer un pointage "Présent"
    if (statuts.isEmpty) {
      return [
        PointageModel(
          numero: numeroEleve.toString(),
          nomEleve: nomEleve,
          classe: classe,
          jour: jour,
          horaire: horaire,
          date: dateTime,
          statut: 'Présent',
          idEleve: idEleve,
        ),
      ];
    }

    // Créer un pointage par critère sélectionné
    return statuts
        .map(
          (statut) => PointageModel(
            numero: numeroEleve.toString(),
            nomEleve: nomEleve,
            classe: classe,
            jour: jour,
            horaire: horaire,
            date: dateTime,
            statut: statut,
            idEleve: idEleve,
          ),
        )
        .toList();
  }

  /// Crée un PointageModel à partir d'une Map de données
  /// Les clés de la map doivent correspondre aux en-têtes de la feuille de calcul
  factory PointageModel.fromMap(Map<String, dynamic> map) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Essayer de parser la date depuis différentes colonnes possibles
    DateTime date;
    try {
      date = dateFormat.parse(map['Date'] ?? map['date'] ?? '');
    } catch (e) {
      date = DateTime.now();
    }

    return PointageModel(
      numero: map['Numéro']?.toString() ?? map['N°']?.toString() ?? '',
      nomEleve: map['Nom']?.toString() ?? map['Nom Élève']?.toString() ?? '',
      classe: map['Classe']?.toString() ?? '',
      jour: map['Jour']?.toString() ?? '',
      horaire: map['Horaire']?.toString() ?? '',
      date: date,
      statut:
          map['Statut']?.toString() ?? map['Critère']?.toString() ?? 'Inconnu',
      idEleve: map['ID_Élève']?.toString() ?? map['ID']?.toString() ?? '',
    );
  }

  /// Convertit le modèle en liste de valeurs pour Google Sheets
  /// Format: [N°, Nom, Classe, Jour, Horaire, Date, Statut, ID_Élève]
  List<Object> toSheetRow() {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    return [
      numero, // Colonne A: Numéro
      nomEleve, // Colonne B: Nom
      classe, // Colonne C: Classe
      jour, // Colonne D: Jour
      horaire, // Colonne E: Horaire
      dateFormatter.format(date), // Colonne F: Date (format court)
      statut, // Colonne G: Statut
      idEleve, // Colonne H: ID Élève
    ];
  }

  /// Crée un PointageModel depuis une ligne de Google Sheets
  factory PointageModel.fromSheetRow(List<dynamic> row) {
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return PointageModel(
      numero: row.isNotEmpty && row[0] != null ? row[0].toString() : '0',
      nomEleve: row.length > 1 && row[1] != null ? row[1].toString() : '',
      classe: row.length > 2 && row[2] != null ? row[2].toString() : '',
      jour: row.length > 3 && row[3] != null ? row[3].toString() : '',
      horaire: row.length > 4 && row[4] != null ? row[4].toString() : '',
      date: row.length > 5 && row[5] != null && row[5].toString().isNotEmpty
          ? _parseDate(row[5].toString(), dateFormatter)
          : DateTime.now(),
      statut: row.length > 6 && row[6] != null ? row[6].toString() : 'Présent',
      idEleve: row.length > 7 && row[7] != null ? row[7].toString() : '',
    );
  }

  /// Parse une date avec gestion des erreurs
  static DateTime _parseDate(String dateStr, DateFormat formatter) {
    try {
      return formatter.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Convertit le modèle en JSON
  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'nomEleve': nomEleve,
      'classe': classe,
      'jour': jour,
      'horaire': horaire,
      'date': date.toIso8601String(),
      'statut': statut,
      'idEleve': idEleve,
    };
  }

  /// Crée un PointageModel depuis JSON
  factory PointageModel.fromJson(Map<String, dynamic> json) {
    return PointageModel(
      numero: json['numero']?.toString() ?? '0',
      nomEleve: json['nomEleve']?.toString() ?? '',
      classe: json['classe']?.toString() ?? '',
      jour: json['jour']?.toString() ?? '',
      horaire: json['horaire']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      statut: json['statut']?.toString() ?? 'Présent',
      idEleve: json['idEleve']?.toString() ?? '',
    );
  }

  /// Copie le modèle avec des modifications
  PointageModel copyWith({
    String? numero,
    String? nomEleve,
    String? classe,
    String? jour,
    String? horaire,
    DateTime? date,
    String? statut,
    String? idEleve,
  }) {
    return PointageModel(
      numero: numero ?? this.numero,
      nomEleve: nomEleve ?? this.nomEleve,
      classe: classe ?? this.classe,
      jour: jour ?? this.jour,
      horaire: horaire ?? this.horaire,
      date: date ?? this.date,
      statut: statut ?? this.statut,
      idEleve: idEleve ?? this.idEleve,
    );
  }

  @override
  String toString() {
    return 'PointageModel(numero: $numero, nomEleve: $nomEleve, classe: $classe, '
        'jour: $jour, horaire: $horaire, date: $date, statut: $statut, idEleve: $idEleve)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PointageModel &&
        other.numero == numero &&
        other.nomEleve == nomEleve &&
        other.classe == classe &&
        other.jour == jour &&
        other.horaire == horaire &&
        other.date == date &&
        other.statut == statut &&
        other.idEleve == idEleve;
  }

  @override
  int get hashCode {
    return numero.hashCode ^
        nomEleve.hashCode ^
        classe.hashCode ^
        jour.hashCode ^
        horaire.hashCode ^
        date.hashCode ^
        statut.hashCode ^
        idEleve.hashCode;
  }
}
