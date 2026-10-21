// lib/presentation/home/google_sheet_state.dart

import 'package:attendance_app/data/models/spreadsheet_info.dart';
import 'package:equatable/equatable.dart';

// ✅ CORRECTION : Constructeurs `const` pour la performance
abstract class SheetState extends Equatable {
  const SheetState();
  @override
  List<Object> get props => [];
}

class SheetInitial extends SheetState {
  const SheetInitial();
}

class SheetLoading extends SheetState {
  const SheetLoading();
}

class SheetError extends SheetState {
  final String message;
  final bool requiresReauthentication;

  const SheetError(this.message, {this.requiresReauthentication = false});
  @override
  List<Object> get props => [message, requiresReauthentication];
}

class SheetDisconnected extends SheetState {
  const SheetDisconnected();
}

class SheetSelection extends SheetState {
  final List<SpreadsheetInfo> availableSheets;
  const SheetSelection({required this.availableSheets});
  @override
  List<Object> get props => [availableSheets];
}

class SheetConnected extends SheetState {
  final String sheetId;
  final String sheetTitle;
  final int classCount;
  final DateTime timestamp;

  String get spreadsheetId => sheetId;

  // ✅ CORRECTION : Le constructeur n'est PAS const car il utilise DateTime.now()
  SheetConnected({
    required this.sheetId,
    required this.sheetTitle,
    this.classCount = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  SheetConnected copyWith({
    String? sheetId,
    String? sheetTitle,
    int? classCount,
  }) {
    return SheetConnected(
      sheetId: sheetId ?? this.sheetId,
      sheetTitle: sheetTitle ?? this.sheetTitle,
      classCount: classCount ?? this.classCount,
      timestamp: DateTime.now(), // Force le rafraîchissement
    );
  }

  @override
  List<Object> get props => [sheetId, sheetTitle, classCount, timestamp];
}

abstract class SeancesState extends Equatable {
  const SeancesState();
  @override
  List<Object> get props => [];
}

class SeancesIdle extends SeancesState {
  const SeancesIdle();
}

class SeancesLoading extends SeancesState {
  const SeancesLoading();
}

class SeancesError extends SeancesState {
  final String message;
  const SeancesError(this.message);
  @override
  List<Object> get props => [message];
}

class SeancesSuccess extends SeancesState {
  final int seancesCount;
  const SeancesSuccess(this.seancesCount);
  @override
  List<Object> get props => [seancesCount];
}
