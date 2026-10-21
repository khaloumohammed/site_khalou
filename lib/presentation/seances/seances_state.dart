import 'package:attendance_app/data/models/seance_model.dart';

/// États du Cubit des séances (renommé SessionState pour éviter les conflits)
abstract class SessionState {
  const SessionState();
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionLoaded extends SessionState {
  final List<SeanceModel> seances;
  const SessionLoaded(this.seances);
}

class SessionError extends SessionState {
  final String message;
  const SessionError(this.message);
}
