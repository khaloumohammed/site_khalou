import 'package:equatable/equatable.dart';

/// Modèle de données pour une classe
class ClassModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final int studentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ClassModel({
    required this.id,
    required this.name,
    this.description = '',
    this.studentCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor pour créer une nouvelle classe
  factory ClassModel.create({required String name, String description = ''}) {
    return ClassModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Copie avec modifications
  ClassModel copyWith({
    String? id,
    String? name,
    String? description,
    int? studentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      studentCount: studentCount ?? this.studentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    studentCount,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'ClassModel(id: $id, name: $name, description: $description, studentCount: $studentCount)';
  }
}
