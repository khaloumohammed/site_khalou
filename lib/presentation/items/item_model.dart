import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/attendance_item.dart';

part '../../data/models/item_model.g.dart'; // Fichier généré par build_runner

@JsonSerializable()
class ItemModel {
  final int id;
  final String critere;

  ItemModel({required this.id, required this.critere});

  // Factory constructor pour la désérialisation (JSON -> Model)
  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  // Méthode pour la sérialisation (Model -> JSON)
  Map<String, dynamic> toJson() => _$ItemModelToJson(this);

  // Conversion du Model vers l'Entité (Domain)
  AttendanceItem toEntity() {
    return AttendanceItem(id: id, critere: critere);
  }
}
