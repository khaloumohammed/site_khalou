import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'base_google_sheets_service.dart';

// Type pour les données de pointage
typedef PointageData = Map<String, dynamic>;

/// Service pour la gestion des élèves dans Google Sheets
class ElevesService extends BaseGoogleSheetsService {
  ElevesService(super._authService);

  /// Récupère la liste des élèves d'une classe spécifique
  Future<List<Map<String, dynamic>>> getElevesByClasse(
    String spreadsheetId,
    String classe,
  ) async {
    try {
      final sheetsApi = await getSheetsApi();
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Elèves',
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        return [];
      }

      final headers = values.first.map((e) => e.toString()).toList();
      final data = values.skip(1);

      final eleves = <Map<String, dynamic>>[];

      for (final row in data) {
        final eleve = <String, dynamic>{};
        for (var i = 0; i < row.length && i < headers.length; i++) {
          eleve[headers[i]] = row[i].toString();
        }

        if (eleve['Classe']?.toLowerCase() == classe.toLowerCase()) {
          eleves.add(eleve);
        }
      }

      return eleves;
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère les données des élèves absents depuis l'onglet Pointage
  /// en filtrant selon les critères écrits dans K2:O2
  Future<List<Map<String, String>>> getAbsentsData({
    required String spreadsheetId,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // 1. Lire les critères de filtrage depuis K2:O2
      final criteresResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!K2:O2',
      );

      if (criteresResponse.values == null || criteresResponse.values!.isEmpty) {
        return [];
      }

      final criteres = criteresResponse.values!.first;

      if (criteres.length < 5) {
        return [];
      }

      final classeFiltre = criteres[0].toString().trim();
      final jourFiltre = criteres[1].toString().trim();
      final horaireFiltre = criteres[2].toString().trim();
      final dateFiltre = criteres[3].toString().trim();
      final statutFiltre = criteres[4].toString().trim().toLowerCase();

      // 2. Lire toutes les données de pointage depuis A2:G
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!A2:G',
      );

      final values = response.values ?? [];

      if (values.isEmpty) {
        return [];
      }

      // 3. Filtrer les données selon les critères
      final absents = <Map<String, String>>[];

      for (var i = 0; i < values.length; i++) {
        final row = values[i];

        // Vérifier que la ligne a suffisamment de colonnes
        if (row.length < 7) {
          continue;
        }

        // Extraire les valeurs (selon les colonnes A à G)
        final numero = row[0].toString().trim();
        final nom = row[1].toString().trim();
        final classe = row[2].toString().trim();
        final jour = row[3].toString().trim();
        final horaire = row[4].toString().trim();
        final date = row[5].toString().trim();
        final statut = row[6].toString().trim().toLowerCase();

        // Appliquer les filtres
        final matchClasse = classe == classeFiltre;
        final matchJour = jour == jourFiltre;
        final matchHoraire = horaire == horaireFiltre;
        final matchDate = date == dateFiltre;
        final matchStatut = statut == statutFiltre;

        if (matchClasse &&
            matchJour &&
            matchHoraire &&
            matchDate &&
            matchStatut) {
          absents.add({
            'N°': numero,
            'Nom': nom,
            'Prenom': '', // Si vous avez une colonne prénom, ajustez ici
            'Classe': classe,
            'Jour': jour,
            'Horaire': horaire,
            'Date': date,
            'Statut': row[6].toString(), // Garder la casse originale
          });
        }
      }

      return absents;
    } catch (e) {
      rethrow;
    }
  }

  /// Version flexible qui récupère tous les pointages d'une séance sans filtrer par date
  Future<List<Map<String, String>>> getPointagesBySeanceFlexible({
    required String spreadsheetId,
    required String classe,
    required String jour,
    required String horaire,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Lire toutes les données de pointage
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!A:Z',
      );

      final values = response.values ?? [];

      if (values.length <= 1) {
        return [];
      }

      // Récupérer les en-têtes
      final headers = values.first.map((e) => e.toString()).toList();

      // Trouver les index des colonnes nécessaires
      final numeroIndex = headers.indexWhere((h) => h.toLowerCase() == 'n°');
      final nomIndex = headers.indexWhere((h) => h.toLowerCase() == 'nom');
      final classeIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'classe',
      );
      final jourIndex = headers.indexWhere((h) => h.toLowerCase() == 'jour');
      final horaireIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'horaire',
      );
      final dateIndex = headers.indexWhere((h) => h.toLowerCase() == 'date');
      final statutIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'statut',
      );

      final pointages = <Map<String, String>>[];

      // Parcourir les lignes de données (en sautant l'en-tête)
      for (var i = 1; i < values.length; i++) {
        final row = values[i];

        // Extraire les valeurs selon les index trouvés
        final rowClasse = classeIndex != -1 && row.length > classeIndex
            ? row[classeIndex].toString().trim()
            : '';
        final rowJour = jourIndex != -1 && row.length > jourIndex
            ? row[jourIndex].toString().trim()
            : '';
        final rowHoraire = horaireIndex != -1 && row.length > horaireIndex
            ? row[horaireIndex].toString().trim()
            : '';
        final rowDate = dateIndex != -1 && row.length > dateIndex
            ? row[dateIndex].toString().trim()
            : '';

        // Filtrer selon les critères de la séance SANS filtre de date
        if (rowClasse == classe && rowJour == jour && rowHoraire == horaire) {
          final pointage = <String, String>{};

          // Ajouter toutes les colonnes disponibles
          if (numeroIndex != -1 && row.length > numeroIndex) {
            pointage['N°'] = row[numeroIndex].toString().trim();
          }
          if (nomIndex != -1 && row.length > nomIndex) {
            pointage['Nom'] = row[nomIndex].toString().trim();
          }
          pointage['Classe'] = rowClasse;
          pointage['Jour'] = rowJour;
          pointage['Horaire'] = rowHoraire;
          pointage['Date'] = rowDate; // Garder la date pour information
          if (statutIndex != -1 && row.length > statutIndex) {
            pointage['Statut'] = row[statutIndex].toString().trim();
          }
          pointage['Prenom'] = ''; // Par défaut

          pointages.add(pointage);
        }
      }

      return pointages;
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère tous les pointages d'une classe (toutes séances, toutes dates)
  Future<List<Map<String, String>>> getPointagesByClasseFlexible({
    required String spreadsheetId,
    required String classe,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!A:Z',
      );

      final values = response.values ?? [];
      if (values.length <= 1) {
        return [];
      }

      final headers = values.first.map((e) => e.toString()).toList();

      final numeroIndex = headers.indexWhere((h) => h.toLowerCase() == 'n°');
      final nomIndex = headers.indexWhere((h) => h.toLowerCase() == 'nom');
      final classeIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'classe',
      );
      final jourIndex = headers.indexWhere((h) => h.toLowerCase() == 'jour');
      final horaireIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'horaire',
      );
      final dateIndex = headers.indexWhere((h) => h.toLowerCase() == 'date');
      final statutIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'statut',
      );

      final pointages = <Map<String, String>>[];

      for (var i = 1; i < values.length; i++) {
        final row = values[i];

        final rowClasse = classeIndex != -1 && row.length > classeIndex
            ? row[classeIndex].toString().trim()
            : '';
        if (rowClasse != classe) {
          continue;
        }

        final pointage = <String, String>{};
        if (numeroIndex != -1 && row.length > numeroIndex) {
          pointage['N°'] = row[numeroIndex].toString().trim();
        }
        if (nomIndex != -1 && row.length > nomIndex) {
          pointage['Nom'] = row[nomIndex].toString().trim();
        }

        pointage['Classe'] = rowClasse;
        pointage['Jour'] = jourIndex != -1 && row.length > jourIndex
            ? row[jourIndex].toString().trim()
            : '';
        pointage['Horaire'] = horaireIndex != -1 && row.length > horaireIndex
            ? row[horaireIndex].toString().trim()
            : '';
        pointage['Date'] = dateIndex != -1 && row.length > dateIndex
            ? row[dateIndex].toString().trim()
            : '';
        pointage['Statut'] = statutIndex != -1 && row.length > statutIndex
            ? row[statutIndex].toString().trim()
            : '';
        pointage['Prenom'] = '';

        pointages.add(pointage);
      }

      return pointages;
    } catch (e) {
      rethrow;
    }
  }

  /// Version alternative qui récupère tous les pointages d'une séance sans dépendre des formules
  Future<List<Map<String, String>>> getPointagesBySeance({
    required String spreadsheetId,
    required String classe,
    required String jour,
    required String horaire,
    required String date,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Lire toutes les données de pointage
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!A:Z',
      );

      final values = response.values ?? [];

      if (values.length <= 1) {
        return [];
      }

      // Récupérer les en-têtes
      final headers = values.first.map((e) => e.toString()).toList();

      // Trouver les index des colonnes nécessaires
      final numeroIndex = headers.indexWhere((h) => h.toLowerCase() == 'n°');
      final nomIndex = headers.indexWhere((h) => h.toLowerCase() == 'nom');
      final classeIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'classe',
      );
      final jourIndex = headers.indexWhere((h) => h.toLowerCase() == 'jour');
      final horaireIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'horaire',
      );
      final dateIndex = headers.indexWhere((h) => h.toLowerCase() == 'date');
      final statutIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'statut',
      );

      final pointages = <Map<String, String>>[];

      // Parcourir les lignes de données (en sautant l'en-tête)
      for (var i = 1; i < values.length; i++) {
        final row = values[i];

        // Extraire les valeurs selon les index trouvés
        final rowClasse = classeIndex != -1 && row.length > classeIndex
            ? row[classeIndex].toString().trim()
            : '';
        final rowJour = jourIndex != -1 && row.length > jourIndex
            ? row[jourIndex].toString().trim()
            : '';
        final rowHoraire = horaireIndex != -1 && row.length > horaireIndex
            ? row[horaireIndex].toString().trim()
            : '';
        final rowDate = dateIndex != -1 && row.length > dateIndex
            ? row[dateIndex].toString().trim()
            : '';

        // Afficher les 10 premières lignes pour diagnostic
        if (i <= 10) {}

        // Filtrer selon les critères de la séance
        if (rowClasse == classe &&
            rowJour == jour &&
            rowHoraire == horaire &&
            rowDate == date) {
          final pointage = <String, String>{};

          // Ajouter toutes les colonnes disponibles
          if (numeroIndex != -1 && row.length > numeroIndex) {
            pointage['N°'] = row[numeroIndex].toString().trim();
          }
          if (nomIndex != -1 && row.length > nomIndex) {
            pointage['Nom'] = row[nomIndex].toString().trim();
          }
          pointage['Classe'] = rowClasse;
          pointage['Jour'] = rowJour;
          pointage['Horaire'] = rowHoraire;
          pointage['Date'] = rowDate;
          if (statutIndex != -1 && row.length > statutIndex) {
            pointage['Statut'] = row[statutIndex].toString().trim();
          }
          pointage['Prenom'] = ''; // Par défaut

          pointages.add(pointage);
        }
      }

      return pointages;
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère tous les élèves de la feuille de calcul
  Future<List<Map<String, dynamic>>> getEleves(String spreadsheetId) async {
    try {
      final sheetsApi = await getSheetsApi();
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Elèves',
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        return [];
      }

      final headers = values.first.map((e) => e.toString()).toList();
      final data = values.skip(1);

      return data.map((row) {
        final eleve = <String, dynamic>{};
        for (var i = 0; i < row.length && i < headers.length; i++) {
          eleve[headers[i]] = row[i].toString();
        }
        return eleve;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère la liste de toutes les classes uniques
  Future<List<String>> getUniqueClasses(String spreadsheetId) async {
    try {
      final sheetsApi = await getSheetsApi();

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Elèves!C2:C',
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        return [];
      }

      final classesSet = <String>{};

      for (var row in values) {
        if (row.isNotEmpty && row[0] != null) {
          final classe = row[0].toString().trim();
          if (classe.isNotEmpty) {
            classesSet.add(classe);
          }
        }
      }

      final classesList = classesSet.toList()..sort();

      return classesList;
    } catch (e) {
      rethrow;
    }
  }

  /// Crée un nouvel élève dans la feuille de calcul
  Future<void> createEleveMethod(
    String spreadsheetId,
    Map<String, String> data,
  ) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Récupérer les en-têtes pour s'assurer que les colonnes sont correctes
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Elèves!1:1', // Première ligne pour les en-têtes
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception(
          'Impossible de récupérer les en-têtes de la feuille Elèves',
        );
      }

      final headers = response.values!.first.map((e) => e.toString()).toList();

      // Normalise un nom de colonne/clé pour pouvoir les comparer
      // (insensible à la casse, aux accents, aux "_" et au symbole "°").
      String normalizeKey(String k) {
        return k
            .toLowerCase()
            .replaceAll('é', 'e')
            .replaceAll('è', 'e')
            .replaceAll('°', '')
            .replaceAll('_', '')
            .trim();
      }

      // Les clés de `data` (fournies par l'UI) sont en minuscules
      // ('id', 'numero', 'nom', 'classe', 'genre', 'naissance') alors que
      // les en-têtes de la feuille peuvent être "N°", "Nom", "ID_Elève", etc.
      // On associe donc chaque en-tête à la bonne clé de `data`.
      String? valueForHeader(String header) {
        final normalizedHeader = normalizeKey(header);
        if (normalizedHeader == 'n' || normalizedHeader == 'numero') {
          return data['numero'];
        }
        if (normalizedHeader == 'nom') {
          return data['nom'];
        }
        if (normalizedHeader == 'classe') {
          return data['classe'];
        }
        if (normalizedHeader == 'genre') {
          return data['genre'];
        }
        if (normalizedHeader == 'naissance' || normalizedHeader == 'naissanc') {
          return data['naissance'];
        }
        if (normalizedHeader == 'ideleve' || normalizedHeader == 'id') {
          return data['id'];
        }
        // Repli: correspondance directe sur le nom exact de l'en-tête.
        return data[header];
      }

      // Préparer les valeurs dans l'ordre des colonnes
      final values = <dynamic>[
        for (final header in headers) valueForHeader(header) ?? '',
      ];

      // Plage couvrant exactement les colonnes des en-têtes (ex: A:F),
      // nécessaire pour qu'INSERT_ROWS détecte correctement le tableau et
      // ajoute une nouvelle ligne au lieu d'écraser la dernière écrite.
      final lastColLetter = String.fromCharCode(
        'A'.codeUnitAt(0) + headers.length - 1,
      );

      // Ajouter la nouvelle ligne
      await sheetsApi.spreadsheets.values.append(
        sheets_api.ValueRange(values: [values]),
        spreadsheetId,
        'Elèves!A:$lastColLetter',
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Met à jour un élève existant dans la feuille de calcul
  Future<void> updateEleveMethod(
    String spreadsheetId,
    String id,
    Map<String, String> data,
  ) async {
    try {
      final sheetsApi = await getSheetsApi();

      // 1. Récupérer toutes les données pour trouver la ligne à mettre à jour
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Elèves!A:F',
      );

      if (response.values == null || response.values!.length <= 1) {
        throw Exception('Aucune donnée trouvée dans la feuille Elèves');
      }

      final headers = response.values!.first.map((e) => e.toString()).toList();
      final dataRows = response.values!.skip(1).toList();

      // 2. Trouver l'index de la colonne ID
      // L'ID peut être dans différentes colonnes: ID_Elève, ID_Élève, id, ID
      final idColumnIndex = headers.indexWhere((h) {
        final normalized = h
            .toLowerCase()
            .replaceAll('_', '')
            .replaceAll('é', 'e')
            .replaceAll('è', 'e');
        return normalized == 'ideleve' || normalized == 'id';
      });

      if (idColumnIndex == -1) {
        throw Exception('Colonne ID non trouvée dans les headers: $headers');
      }

      int rowIndex = -1;
      for (int i = 0; i < dataRows.length; i++) {
        if (dataRows[i].length > idColumnIndex) {
          final rowId = dataRows[i][idColumnIndex].toString().trim();
          if (rowId == id.trim()) {
            rowIndex =
                i + 2; // +2 car l'index commence à 1 et on saute l'en-tête
            break;
          }
        }
      }

      if (rowIndex == -1) {
        throw Exception('Élève non trouvé avec ID: $id');
      }

      // 3. Préparer les valeurs à mettre à jour
      final updatedRow = List<String>.filled(headers.length, '');

      // Remplir avec les anciennes valeurs
      final oldRow = dataRows[rowIndex - 2];
      for (int i = 0; i < oldRow.length && i < updatedRow.length; i++) {
        updatedRow[i] = oldRow[i].toString();
      }

      // Mettre à jour avec les nouvelles valeurs
      data.forEach((key, value) {
        // Normaliser le nom de la clé pour la recherche
        String normalizeKey(String k) {
          return k
              .toLowerCase()
              .replaceAll('é', 'e')
              .replaceAll('è', 'e')
              .replaceAll('°', '')
              .replaceAll('_', '')
              .trim();
        }

        final normalizedKey = normalizeKey(key);
        final columnIndex = headers.indexWhere((h) {
          final normalizedHeader = normalizeKey(h);
          // Correspondances possibles
          if (normalizedKey == 'numero' &&
              (normalizedHeader == 'n' || normalizedHeader == 'numero'))
            return true;
          if (normalizedKey == 'nom' && normalizedHeader == 'nom') return true;
          if (normalizedKey == 'classe' && normalizedHeader == 'classe')
            return true;
          if (normalizedKey == 'genre' && normalizedHeader == 'genre')
            return true;
          if (normalizedKey == 'naissance' && normalizedHeader == 'naissance')
            return true;
          return false;
        });

        if (columnIndex != -1) {
          updatedRow[columnIndex] = value;
        } else {}
      });

      // 4. Mettre à jour la ligne
      await sheetsApi.spreadsheets.values.update(
        sheets_api.ValueRange(values: [updatedRow]),
        spreadsheetId,
        'Elèves!A$rowIndex:F$rowIndex',
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Met à jour le N° de plusieurs élèves en une seule requête (clé: ID élève)
  Future<void> updateNumerosBatch(
    String spreadsheetId,
    Map<String, String> numerosParId,
  ) async {
    final sheetsApi = await getSheetsApi();
    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      'Elèves!A:F',
    );
    final rows = response.values;
    if (rows == null || rows.length <= 1) {
      throw Exception('Aucune donnée trouvée dans la feuille Elèves');
    }

    final headers = rows.first.map((e) => e.toString()).toList();
    String norm(String h) => h
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('°', '')
        .replaceAll('_', '')
        .trim();
    final idCol = headers.indexWhere((h) {
      final n = norm(h);
      return n == 'ideleve' || n == 'id';
    });
    final numCol = headers.indexWhere((h) {
      final n = norm(h);
      return n == 'n' || n == 'numero';
    });
    if (idCol == -1 || numCol == -1) {
      throw Exception('Colonnes ID ou N° introuvables: $headers');
    }

    final colLetter = String.fromCharCode('A'.codeUnitAt(0) + numCol);
    final data = <sheets_api.ValueRange>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= idCol) continue;
      final rowId = row[idCol].toString().trim();
      final nouveau = numerosParId[rowId];
      if (nouveau == null) continue;
      data.add(
        sheets_api.ValueRange(
          range: 'Elèves!$colLetter${i + 1}',
          values: [
            [nouveau],
          ],
        ),
      );
    }
    if (data.isEmpty) return;

    await sheetsApi.spreadsheets.values.batchUpdate(
      sheets_api.BatchUpdateValuesRequest(
        valueInputOption: 'USER_ENTERED',
        data: data,
      ),
      spreadsheetId,
    );
  }

  /// Supprime un élève de la feuille de calcul
  Future<void> deleteEleveMethod(String spreadsheetId, String id) async {
    try {
      final sheetsApi = await getSheetsApi();

      // 1. Récupérer les métadonnées du spreadsheet pour obtenir le sheetId de l'onglet Elèves
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      int? elevesSheetId;

      for (var sheet in spreadsheet.sheets ?? []) {
        if (sheet.properties?.title == 'Elèves') {
          elevesSheetId = sheet.properties?.sheetId;
          break;
        }
      }

      if (elevesSheetId == null) {
        throw Exception('Onglet Elèves non trouvé dans le spreadsheet');
      }

      // 2. Récupérer toutes les données pour trouver la ligne à supprimer
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Elèves!A:F',
      );

      if (response.values == null || response.values!.length <= 1) {
        throw Exception('Aucune donnée trouvée dans la feuille Elèves');
      }

      final headers = response.values!.first.map((e) => e.toString()).toList();
      final dataRows = response.values!.skip(1).toList();

      // 3. Trouver l'index de la colonne ID
      final idColumnIndex = headers.indexWhere((h) {
        final normalized = h
            .toLowerCase()
            .replaceAll('_', '')
            .replaceAll('é', 'e')
            .replaceAll('è', 'e');
        return normalized == 'ideleve' || normalized == 'id';
      });

      if (idColumnIndex == -1) {
        throw Exception('Colonne ID non trouvée dans les headers: $headers');
      }

      // 4. Trouver l'index de la ligne à supprimer
      int rowIndex = -1;
      for (int i = 0; i < dataRows.length; i++) {
        if (dataRows[i].length > idColumnIndex) {
          final rowId = dataRows[i][idColumnIndex].toString().trim();
          if (rowId == id.trim()) {
            rowIndex =
                i + 2; // +2 car l'index commence à 1 et on saute l'en-tête
            break;
          }
        }
      }

      if (rowIndex == -1) {
        throw Exception('Élève non trouvé avec ID: $id');
      }

      // 5. Créer une requête pour supprimer la ligne
      final request = sheets_api.BatchUpdateSpreadsheetRequest(
        requests: [
          sheets_api.Request(
            deleteDimension: sheets_api.DeleteDimensionRequest(
              range: sheets_api.DimensionRange(
                sheetId: elevesSheetId,
                dimension: 'ROWS',
                startIndex: rowIndex - 1, // Index basé sur 0
                endIndex: rowIndex, // L'index de fin est exclusif
              ),
            ),
          ),
        ],
      );

      // 6. Exécuter la requête de suppression
      await sheetsApi.spreadsheets.batchUpdate(request, spreadsheetId);
    } catch (e) {
      rethrow;
    }
  }

  /// Retourne une liste de Map contenant les données brutes des pointages
  Future<List<PointageData>> getPointagesByEleve({
    required String spreadsheetId,
    required String eleveId,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Lire toutes les données de l'onglet Pointage
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!A:Z', // Ajustez la plage selon vos besoins
      );

      final values = response.values ?? [];

      if (values.length <= 1) {
        // Vérifier s'il y a des données au-delà de l'en-tête
        return [];
      }

      // Récupérer les en-têtes (première ligne)
      final headers = values.first.map((e) => e.toString()).toList();

      // Vérifier si la colonne ID_Élève existe
      final idEleveIndex = headers.indexWhere(
        (h) =>
            h.toLowerCase() == 'id_élève' ||
            h.toLowerCase() == 'id_eleve' ||
            h.toLowerCase() == 'ideleve' ||
            h.toLowerCase() == 'id',
      );
      if (idEleveIndex == -1) {
        return [];
      }

      final pointages = <PointageData>[];

      // Parcourir les lignes de données (en sautant l'en-tête)
      for (var i = 1; i < values.length; i++) {
        final row = values[i];
        if (row.length > idEleveIndex &&
            row[idEleveIndex].toString() == eleveId) {
          final pointageData = <String, dynamic>{};

          // Mapper chaque cellule à son en-tête correspondant
          for (var j = 0; j < headers.length && j < row.length; j++) {
            pointageData[headers[j]] = row[j].toString();
          }

          pointages.add(pointageData);
        }
      }

      // Trier les pointages par date (du plus récent au plus ancien)
      pointages.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      return pointages;
    } catch (e) {
      rethrow;
    }
  }

  /// Vérifie et crée les en-têtes de colonnes si nécessaire
  Future<void> _ensurePointageHeaders(String spreadsheetId) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Vérifier si les en-têtes existent déjà (à partir de la colonne A)
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!A1:H1',
      );

      // Si la première ligne est vide ou n'existe pas, on ajoute les en-têtes
      if (response.values == null || response.values!.isEmpty) {
        final headers = [
          'N°',
          'Nom',
          'Classe',
          'Jour',
          'Horaire',
          'Date',
          'Statut',
          'ID_Élève',
        ];

        await sheetsApi.spreadsheets.values.update(
          sheets_api.ValueRange(values: [headers]),
          spreadsheetId,
          'Pointage!A1',
          valueInputOption: 'USER_ENTERED',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Ajoute plusieurs pointages en une seule opération
  Future<void> appendPointagesBatch({
    required String spreadsheetId,
    required List<List<dynamic>> rows,
  }) async {
    try {
      if (rows.isEmpty) {
        return;
      }

      final sheetsApi = await getSheetsApi();

      // Vérifier si l'onglet Pointage existe et créer les en-têtes si nécessaire
      await _ensurePointageHeaders(spreadsheetId);

      // Ajouter les pointages à la fin de la feuille (à partir de la colonne A)
      await sheetsApi.spreadsheets.values.append(
        sheets_api.ValueRange(values: rows),
        spreadsheetId,
        'Pointage!A:H', // Colonnes A à H (8 colonnes)
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère l'historique de pointage d'un élève spécifique
  /// Écrit l'ID dans S2 puis lit les résultats calculés dans S3:Z.
  /// Mapping des colonnes demandé:
  /// - Date   -> Colonne X
  /// - Jour   -> Colonne V
  /// - Horaire-> Colonne W
  /// - Statut -> Colonne Y
  Future<List<List<String>>> getHistoriquePointage({
    required String spreadsheetId,
    required String eleveId,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // 1) Écrire l'ID élève dans S2
      await sheetsApi.spreadsheets.values.update(
        sheets_api.ValueRange(
          values: [
            [eleveId],
          ],
        ),
        spreadsheetId,
        'Pointage!S2',
        valueInputOption: 'USER_ENTERED',
      );

      // 2) Attendre la mise à jour des formules
      await Future.delayed(const Duration(seconds: 2));

      // 3) Lire les résultats en S3:Z
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!S3:Z',
      );

      final rows = response.values ?? [];
      if (rows.isEmpty) return [];

      // Index des colonnes (0-based à partir de S):
      // S=0, T=1, U=2, V=3, W=4, X=5, Y=6, Z=7
      const idxJour = 3; // V
      const idxHoraire = 4; // W
      const idxDate = 5; // X
      const idxStatut = 6; // Y

      final historique = <List<String>>[];

      for (final row in rows) {
        if (row.isEmpty ||
            row.every((c) => (c?.toString().trim().isEmpty ?? true))) {
          continue;
        }

        String cell(int i) => (i < row.length ? row[i].toString().trim() : '');

        // Ne garder que les données brutes, centrées
        final entry = [
          cell(idxDate), // Date
          cell(idxJour), // Jour
          cell(idxHoraire), // Horaire
          cell(idxStatut), // Statut
        ];

        if (entry.any((v) => v.isNotEmpty)) {
          historique.add(entry);
        }
      }

      return historique;
    } catch (e) {
      rethrow;
    }
  }

  /// Supprime un pointage spécifique d'un élève - Version simplifiée
  Future<bool> deletePointage({
    required String spreadsheetId,
    required String eleveId,
    required String date,
    required String jour,
    required String horaire,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // 1. Obtenir d'abord les métadonnées pour trouver le bon sheetId
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      int pointageSheetId = -1;

      for (var sheet in spreadsheet.sheets!) {
        if (sheet.properties?.title == 'Pointage') {
          pointageSheetId = sheet.properties!.sheetId!;
        }
      }

      if (pointageSheetId == -1) {
        return false;
      }

      // 2. Lire toutes les données de la feuille Pointage
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!A:Z',
      );

      final values = response.values ?? [];

      if (values.length <= 1) {
        return false;
      }

      // 3. Analyser les en-têtes
      final headers = values.first.map((e) => e.toString().trim()).toList();

      // 4. Trouver les index des colonnes importantes
      final idIndex = headers.indexWhere((h) {
        final header = h.toLowerCase().trim();
        return header == 'id_élève' ||
            header == 'id_eleve' ||
            header == 'id_elève' ||
            header == 'id_elève' ||
            header == 'ideleve' ||
            header == 'id' ||
            header == 'id_elve';
      });

      final dateIndex = headers.indexWhere((h) => h.toLowerCase() == 'date');
      final jourIndex = headers.indexWhere((h) => h.toLowerCase() == 'jour');
      final horaireIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'horaire',
      );

      if (idIndex == -1 ||
          dateIndex == -1 ||
          jourIndex == -1 ||
          horaireIndex == -1) {
        return false;
      }

      // 5. Chercher la ligne exacte à supprimer
      int rowToDelete = -1;

      for (var i = 1; i < values.length; i++) {
        final row = values[i];
        if (row.length > idIndex &&
            row.length > dateIndex &&
            row.length > jourIndex &&
            row.length > horaireIndex) {
          final rowId = row[idIndex].toString().trim();
          final rowDate = row[dateIndex].toString().trim();
          final rowJour = row[jourIndex].toString().trim();
          final rowHoraire = row[horaireIndex].toString().trim();

          // Comparaison flexible
          if (rowId == eleveId.trim() &&
              rowDate == date.trim() &&
              rowJour == jour.trim() &&
              rowHoraire == horaire.trim()) {
            rowToDelete = i + 1; // +1 pour Google Sheets (1-based)
            break;
          }
        }
      }

      if (rowToDelete == -1) {
        return false;
      }

      // 6. Supprimer la ligne avec deleteDimension

      final batchRequest = sheets_api.BatchUpdateSpreadsheetRequest(
        requests: [
          sheets_api.Request(
            deleteDimension: sheets_api.DeleteDimensionRequest(
              range: sheets_api.DimensionRange(
                sheetId: pointageSheetId,
                dimension: 'ROWS',
                startIndex: rowToDelete - 1, // 0-based index
                endIndex: rowToDelete, // exclusive
              ),
            ),
          ),
        ],
      );

      await sheetsApi.spreadsheets.batchUpdate(batchRequest, spreadsheetId);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Version alternative qui lit directement les données brutes sans dépendre des formules
  Future<List<List<String>>> getHistoriquePointageDirect({
    required String spreadsheetId,
    required String eleveId,
    String? classe,
    String? jour,
    String? horaire,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Lire toutes les données de l'onglet Pointage
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!A:Z',
      );

      final values = response.values ?? [];
      if (values.length <= 1) {
        return [];
      }

      // Récupérer les en-têtes
      final headers = values.first.map((e) => e.toString()).toList();

      // Trouver l'index de la colonne ID_Élève
      final idEleveIndex = headers.indexWhere((h) {
        final result =
            h.toLowerCase() == 'id_élève' ||
            h.toLowerCase() == 'id_eleve' ||
            h.toLowerCase() == 'id_elève' ||
            h.toLowerCase() == 'ideleve' ||
            h.toLowerCase() == 'id';
        return result;
      });

      if (idEleveIndex == -1) {
        return [];
      }

      // Trouver les index des colonnes nécessaires
      final dateIndex = headers.indexWhere((h) => h.toLowerCase() == 'date');
      final jourIndex = headers.indexWhere((h) => h.toLowerCase() == 'jour');
      final horaireIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'horaire',
      );
      final classeIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'classe',
      );
      final statutIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'statut',
      );

      final filtreClasse = classe?.trim().toLowerCase() ?? '';
      final filtreJour = jour?.trim().toLowerCase() ?? '';
      final filtreHoraire = horaire?.trim().toLowerCase() ?? '';

      final historique = <List<String>>[];

      // Parcourir les lignes de données (en sautant l'en-tête)
      for (var i = 1; i < values.length; i++) {
        final row = values[i];

        // Vérifier si cette ligne correspond à l'élève
        if (row.length > idEleveIndex &&
            row[idEleveIndex].toString().trim() == eleveId.trim()) {
          final rowClasse = classeIndex != -1 && row.length > classeIndex
              ? row[classeIndex].toString().trim().toLowerCase()
              : '';
          final rowJour = jourIndex != -1 && row.length > jourIndex
              ? row[jourIndex].toString().trim().toLowerCase()
              : '';
          final rowHoraire = horaireIndex != -1 && row.length > horaireIndex
              ? row[horaireIndex].toString().trim().toLowerCase()
              : '';

          final matchClasse = filtreClasse.isEmpty || rowClasse == filtreClasse;
          final matchJour = filtreJour.isEmpty || rowJour == filtreJour;
          final matchHoraire =
              filtreHoraire.isEmpty || rowHoraire == filtreHoraire;

          if (!matchClasse || !matchJour || !matchHoraire) {
            continue;
          }

          final entry = <String>[];

          // Ajouter les valeurs dans l'ordre attendu: Date, Jour, Horaire, Statut
          if (dateIndex != -1 && row.length > dateIndex) {
            entry.add(row[dateIndex].toString().trim());
          } else {
            entry.add('');
          }

          if (jourIndex != -1 && row.length > jourIndex) {
            entry.add(row[jourIndex].toString().trim());
          } else {
            entry.add('');
          }

          if (horaireIndex != -1 && row.length > horaireIndex) {
            entry.add(row[horaireIndex].toString().trim());
          } else {
            entry.add('');
          }

          if (statutIndex != -1 && row.length > statutIndex) {
            entry.add(row[statutIndex].toString().trim());
          } else {
            entry.add('');
          }

          if (entry.any((v) => v.isNotEmpty)) {
            historique.add(entry);
          }
        }
      }

      return historique;
    } catch (e) {
      rethrow;
    }
  }
}
