import 'package:equatable/equatable.dart';

class SpreadsheetInfo extends Equatable {
  final String id;
  final String title;

  const SpreadsheetInfo({required this.id, required this.title});

  @override
  List<Object> get props => [id, title];
}
