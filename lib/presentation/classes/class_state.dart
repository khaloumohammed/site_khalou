import 'class_model.dart';

/// États du Cubit des classes
abstract class ClassState {
  const ClassState();
}

class ClassInitial extends ClassState {}

class ClassLoading extends ClassState {}

class ClassLoaded extends ClassState {
  final List<ClassModel> classes;
  const ClassLoaded(this.classes);
}

class ClassError extends ClassState {
  final String message;
  const ClassError(this.message);
}

class ClassOperationSuccess extends ClassState {
  final String message;
  const ClassOperationSuccess(this.message);
}
