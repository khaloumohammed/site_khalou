import 'package:equatable/equatable.dart';

/// Modèle de données pour une séance
class SeanceModel extends Equatable {
  final String id;
  final String jour;
  final String horaire;
  final String classe;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SeanceModel({
    required this.id,
    required this.jour,
    required this.horaire,
    required this.classe,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor pour créer une nouvelle séance
  factory SeanceModel.create({
    required String jour,
    required String horaire,
    required String classe,
  }) {
    return SeanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jour: jour,
      horaire: horaire,
      classe: classe,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Factory constructor pour créer depuis les données Google Sheets
  factory SeanceModel.fromSheetData({
    required String jour,
    required String horaire,
    required String classe,
  }) {
    return SeanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jour: jour,
      horaire: horaire,
      classe: classe,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Copie avec modifications
  SeanceModel copyWith({
    String? id,
    String? jour,
    String? horaire,
    String? classe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SeanceModel(
      id: id ?? this.id,
      jour: jour ?? this.jour,
      horaire: horaire ?? this.horaire,
      classe: classe ?? this.classe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convertir en Map pour Google Sheets
  Map<String, dynamic> toSheetData() {
    return {
      'id': id,
      'jour': jour,
      'horaire': horaire,
      'classe': classe,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, jour, horaire, classe, createdAt, updatedAt];

  @override
  String toString() {
    return 'SeanceModel(id: $id, jour: $jour, horaire: $horaire, classe: $classe)';
  }
}
