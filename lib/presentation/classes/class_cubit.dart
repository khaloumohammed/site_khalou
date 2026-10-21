import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/presentation/classes/class_state.dart';
import 'package:attendance_app/presentation/classes/class_model.dart';
import 'package:attendance_app/core/services/eleves_service.dart';
import 'package:attendance_app/core/services/auth_service.dart';

class ClassCubit extends Cubit<ClassState> {
  final ElevesService _elevesService;

  List<ClassModel> _classes = [];

  ClassCubit({
    required ElevesService elevesService,
    required AuthService authService,
  }) : _elevesService = elevesService,
       super(ClassInitial());

  /// Charge les classes depuis Google Sheets
  Future<void> loadClasses(String spreadsheetId) async {
    emit(ClassLoading());

    try {
      // Récupérer les classes uniques depuis Google Sheets
      final classNames = await _elevesService.getUniqueClasses(spreadsheetId);

      // Récupérer le nombre d'élèves par classe
      final studentCountByClass = <String, int>{};

      // Pour chaque classe, récupérer le nombre d'élèves
      for (final className in classNames) {
        final eleves = await _elevesService.getElevesByClasse(
          spreadsheetId,
          className,
        );
        studentCountByClass[className] = eleves.length;
      }

      // Convertir les noms en modèles de classes avec le nombre d'élèves
      _classes = classNames.map((name) {
        final studentCount = studentCountByClass[name] ?? 0;
        return ClassModel.create(
          name: name,
          description: 'Classe importée depuis Google Sheets',
        ).copyWith(studentCount: studentCount);
      }).toList();

      emit(ClassLoaded(_classes));
    } catch (e) {
      emit(
        ClassError('Erreur lors du chargement des classes: ${e.toString()}'),
      );
    }
  }

  /// Ajoute une nouvelle classe
  void addClass(String name, {String description = ''}) {
    if (name.trim().isEmpty) {
      emit(ClassError('Le nom de la classe ne peut pas être vide'));
      return;
    }

    // Vérifier si une classe avec ce nom existe déjà
    final existingClass = _classes
        .where((c) => c.name.toLowerCase() == name.toLowerCase())
        .toList();

    if (existingClass.isNotEmpty) {
      emit(ClassError('Une classe avec ce nom existe déjà'));
      return;
    }

    final newClass = ClassModel.create(
      name: name.trim(),
      description: description.trim(),
    );

    _classes.add(newClass);
    emit(ClassLoaded(_classes));
  }

  /// Met à jour une classe existante
  void updateClass(String classId, String name, {String description = ''}) {
    if (name.trim().isEmpty) {
      emit(ClassError('Le nom de la classe ne peut pas être vide'));
      return;
    }

    final classIndex = _classes.indexWhere((c) => c.id == classId);
    if (classIndex == -1) {
      emit(ClassError('Classe non trouvée'));
      return;
    }

    // Vérifier si une autre classe avec ce nom existe déjà
    final existingClass = _classes
        .where(
          (c) => c.id != classId && c.name.toLowerCase() == name.toLowerCase(),
        )
        .toList();

    if (existingClass.isNotEmpty) {
      emit(ClassError('Une autre classe avec ce nom existe déjà'));
      return;
    }

    _classes[classIndex] = _classes[classIndex].copyWith(
      name: name.trim(),
      description: description.trim(),
      updatedAt: DateTime.now(),
    );

    emit(ClassLoaded(_classes));
  }

  /// Supprime une classe
  void deleteClass(String classId) {
    final classIndex = _classes.indexWhere((c) => c.id == classId);
    if (classIndex == -1) {
      emit(ClassError('Classe non trouvée'));
      return;
    }

    _classes.removeAt(classIndex);

    emit(ClassLoaded(_classes));
  }

  /// Recherche des classes par nom
  void searchClasses(String query) {
    if (query.trim().isEmpty) {
      emit(ClassLoaded(_classes));
      return;
    }

    final filteredClasses = _classes
        .where(
          (c) =>
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    emit(ClassLoaded(filteredClasses));
  }

  /// Réinitialise la recherche
  void resetSearch() {
    emit(ClassLoaded(_classes));
  }
}
