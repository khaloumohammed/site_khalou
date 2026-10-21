import 'package:dartz/dartz.dart';
import 'package:attendance_app/domain/repositories/eleve_repository.dart';

// Définition d'une erreur simple pour l'exemple
class CreateEleveFailure {
  final String message;
  CreateEleveFailure([this.message = "Erreur lors de la création"]);

  @override
  String toString() => message;
}

class CreateEleve {
  final EleveRepository repository;

  CreateEleve(this.repository);

  /// Exécute la création d'un élève
  /// L'ID DOIT être fourni dans data avec le format: numero_classe
  /// Utilise un Either (erreur/succes) pour une gestion d'erreur propre
  Future<Either<CreateEleveFailure, void>> call(
    String spreadsheetId,
    Map<String, String> data,
  ) async {
    try {
      // Validation des champs requis
      final numero = data['numero']?.trim() ?? '';
      final classe = data['classe']?.trim() ?? '';
      final nom = data['nom']?.trim() ?? '';

      if (numero.isEmpty) {
        return Left(CreateEleveFailure("Le numéro de l'élève est requis"));
      }
      if (classe.isEmpty) {
        return Left(CreateEleveFailure("La classe est requise"));
      }
      if (nom.isEmpty) {
        return Left(CreateEleveFailure("Le nom de l'élève est requis"));
      }

      // 2) Génération/Validation de l'ID = numero_classe
      final expectedId = "${numero}_$classe";
      final providedId = data['id']?.trim() ?? '';

      String finalId;
      if (providedId.isEmpty) {
        // ID non fourni, on le génère
        finalId = expectedId;
      } else if (providedId != expectedId) {
        // ID fourni mais incorrect, on force le bon format
        finalId = expectedId;
      } else {
        // ID correct fourni
        finalId = providedId;
      }

      // 3) Enrichissement des données avec l'ID correct
      final enrichedData = {
        ...data,
        'id': finalId,
        'numero': numero,
        'classe': classe,
        'nom': nom,
      };

      // 4) Vérification des doublons par ID
      final eleves = await repository.getEleves(spreadsheetId);
      final hasDuplicate = eleves.any((e) => e.id == finalId);

      if (hasDuplicate) {
        return Left(
          CreateEleveFailure(
            "Un élève avec le numéro $numero existe déjà dans la classe $classe (ID: $finalId)",
          ),
        );
      }

      // 5) Création avec les données enrichies
      await repository.createEleveMethod(spreadsheetId, enrichedData);

      return const Right(null); // Succès
    } catch (e) {
      return Left(CreateEleveFailure("Erreur lors de la création: $e"));
    }
  }

  /// Méthode utilitaire pour générer un ID d'élève
  /// Format standard: classe_numero
  /// Exemple: "6A_12" pour l'élève n°12 de la classe 6A
  static String generateEleveId(String classe, String numero) {
    return "${classe.trim()}_${numero.trim()}";
  }

  /// Vérifie si un ID a le bon format
  static bool isValidEleveId(String id, String classe, String numero) {
    final expectedId = generateEleveId(classe, numero);
    return id == expectedId;
  }
}
