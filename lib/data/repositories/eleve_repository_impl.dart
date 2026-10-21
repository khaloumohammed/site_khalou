import 'package:attendance_app/core/services/eleves_service.dart';
import 'package:attendance_app/domain/entities/attendance_eleve.dart';
import 'package:attendance_app/domain/repositories/eleve_repository.dart';
import 'package:attendance_app/presentation/eleves/eleve_model.dart';

class EleveRepositoryImpl implements EleveRepository {
  final ElevesService _elevesService;

  EleveRepositoryImpl(this._elevesService);

  @override
  Future<List<Eleve>> getElevesByClasse(
    String spreadsheetId,
    String classe,
  ) async {
    try {
      // Récupérer les données brutes des élèves de la classe
      final elevesData = await _elevesService.getElevesByClasse(
        spreadsheetId,
        classe,
      );

      // Convertir les données brutes en objets Eleve
      final eleves = elevesData.map((data) {
        // Debug: afficher les clés disponibles

        return Eleve(
          // Mapper correctement les champs selon les colonnes de Google Sheets
          id:
              data['ID_Elève']?.toString() ??
              data['ID_Élève']?.toString() ??
              '',
          numero: data['N°']?.toString() ?? '',
          nom: data['Nom']?.toString() ?? '',
          classe:
              data['Classe']?.toString() ??
              classe, // Utiliser la classe passée en paramètre si non disponible
          genre:
              data['Genre']?.toString().toUpperCase() ??
              'G', // G ou F en majuscule
          naissance:
              data['Naissance']?.toString() ??
              data['Naissanc']?.toString() ??
              '',
        );
      }).toList();

      // Debug: afficher quelques élèves pour vérification
      if (eleves.isNotEmpty) {}

      return eleves;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AttendanceEleve>> getEleves(String spreadsheetId) async {
    try {
      final elevesData = await _elevesService.getEleves(spreadsheetId);

      final eleves = elevesData
          .map((data) {
            try {
              // Mapper les en-têtes Google Sheets (avec majuscules/accents) aux champs
              final eleve = AttendanceEleve(
                id:
                    data['ID_Elève']?.toString().trim() ??
                    data['ID_Élève']?.toString().trim() ??
                    data['id']?.toString().trim() ??
                    '',
                numero:
                    data['N°']?.toString().trim() ??
                    data['Numero']?.toString().trim() ??
                    '',
                nom:
                    data['Nom']?.toString().trim() ??
                    data['nom']?.toString().trim() ??
                    '',
                classe:
                    data['Classe']?.toString().trim() ??
                    data['classe']?.toString().trim() ??
                    '',
                genre:
                    data['Genre']?.toString().trim() ??
                    data['genre']?.toString().trim() ??
                    '',
                naissance:
                    data['Naissance']?.toString().trim() ??
                    data['naissance']?.toString().trim() ??
                    '',
                age: _computeAgeFromYear(
                  data['Naissance']?.toString() ??
                      data['naissance']?.toString(),
                ),
              );

              // Validation des données essentielles
              if (eleve.nom.isEmpty) {
                return null;
              }

              return eleve;
            } catch (e) {
              return null;
            }
          })
          .where((eleve) => eleve != null)
          .cast<AttendanceEleve>()
          .toList();

      return eleves;
    } catch (e) {
      throw Exception("Erreur lors de la récupération des élèves: $e");
    }
  }

  @override
  Future<void> createEleveMethod(
    String spreadsheetId,
    Map<String, String> data,
  ) async {
    try {
      // Validation que l'ID est fourni
      if (!data.containsKey('id') || data['id']!.trim().isEmpty) {
        throw Exception(
          "L'ID de l'élève doit être fourni (format: numero_classe)",
        );
      }

      // Validation des données requises
      final requiredFields = [
        'id',
        'nom',
        'numero',
        'classe',
        'genre',
        'naissance',
      ];
      for (final field in requiredFields) {
        if (data[field] == null || data[field]!.trim().isEmpty) {
          throw Exception("Le champ '$field' est requis");
        }
      }

      // Vérification du format d'ID (doit être classe_numero)
      final id = data['id']!;
      final numero = data['numero']!;
      final classe = data['classe']!;
      final expectedId = "${classe}_$numero";

      if (id != expectedId) {
        // On force le bon format
        final correctedData = {...data, 'id': expectedId};
        await _elevesService.createEleveMethod(spreadsheetId, correctedData);
      } else {
        await _elevesService.createEleveMethod(spreadsheetId, data);
      }
    } catch (e) {
      throw Exception(
        "Erreur lors de la création de l'élève '${data['nom'] ?? ''}': $e",
      );
    }
  }

  @override
  Future<void> updateEleveMethod(
    String spreadsheetId,
    String id,
    Map<String, String> data,
  ) async {
    try {
      if (id.isEmpty) {
        throw Exception("ID d'élève invalide pour la mise à jour");
      }

      // Validation qu'au moins un champ est fourni
      final hasValidData = data.values.any((value) => value.trim().isNotEmpty);
      if (!hasValidData) {
        throw Exception("Aucune donnée valide fournie pour la mise à jour");
      }

      // IMPORTANT: Si numero ou classe changent, l'ID doit être recalculé
      if (data.containsKey('numero') || data.containsKey('classe')) {
        // Pour l'instant, on laisse le service gérer cette logique
      }

      await _elevesService.updateEleveMethod(spreadsheetId, id, data);
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour de l'élève '$id': $e");
    }
  }

  @override
  Future<void> updateNumerosBatch(
    String spreadsheetId,
    Map<String, String> numerosParId,
  ) => _elevesService.updateNumerosBatch(spreadsheetId, numerosParId);

  @override
  Future<void> deleteEleveMethod(String spreadsheetId, String id) async {
    try {
      if (id.isEmpty) {
        throw Exception("ID d'élève invalide pour la suppression");
      }

      await _elevesService.deleteEleveMethod(spreadsheetId, id);
    } catch (e) {
      throw Exception("Erreur lors de la suppression de l'élève '$id': $e");
    }
  }

  // Helper interne pour calculer l'âge à partir de l'année de naissance
  String _computeAgeFromYear(String? yearStr) {
    try {
      if (yearStr == null || yearStr.trim().isEmpty) return '';

      final trimmed = yearStr.trim();

      // Extraire l'année avec une regex pour plus de robustesse
      final yearMatch = RegExp(r'(\d{4})').firstMatch(trimmed);
      final yearString = yearMatch?.group(1) ?? trimmed;

      final year = int.tryParse(yearString);
      if (year == null) {
        return '';
      }

      final now = DateTime.now();
      final age = now.year - year;

      // Validation de l'âge raisonnable (entre 3 et 25 ans)
      if (age < 3 || age > 25) {
        return age > 0 ? age.toString() : '';
      }

      return age.toString();
    } catch (e) {
      return '';
    }
  }

  // Méthode utilitaire pour valider les données d'un élève
  // ignore: unused_element
  bool _validateEleveData(Map<String, String> data) {
    final requiredFields = ['nom', 'numero', 'classe'];
    for (final field in requiredFields) {
      if (data[field] == null || data[field]!.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Génère un ID unique au format: classe_numero
  /// Format standard pour toute l'application
  /// Exemple: "6A_12" pour l'élève n°12 de la classe 6A
  /// Cette méthode garantit la cohérence du format d'ID
  static String generateEleveId(String classe, String numero) {
    return "${classe.trim()}_${numero.trim()}";
  }
}
