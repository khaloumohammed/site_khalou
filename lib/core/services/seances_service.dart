import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'base_google_sheets_service.dart';

/// Service pour la gestion des séances dans Google Sheets
class SeancesService extends BaseGoogleSheetsService {
  SeancesService(super._authService);

  /// Récupère la liste de toutes les séances
  Future<List<Map<String, String>>> getSeances(String spreadsheetId) async {
    try {
      final sheetsApi = await getSheetsApi();

      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheetNames = (spreadsheet.sheets ?? [])
          .map((s) => s.properties?.title)
          .where((t) => t != null)
          .map((t) => t!)
          .toList();

      final seancesExists = sheetNames.contains('Séances');

      if (!seancesExists) {
        return [];
      }

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Séances!A2:C',
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        return [];
      }

      final seances = <Map<String, String>>[];

      for (var i = 0; i < values.length; i++) {
        final row = values[i];
        if (row.length >= 3 &&
            row[0] != null &&
            row[1] != null &&
            row[2] != null) {
          final jour = row[0].toString().trim();
          final horaire = row[1].toString().trim();
          final classe = row[2].toString().trim();

          if (jour.isNotEmpty && horaire.isNotEmpty && classe.isNotEmpty) {
            seances.add({'jour': jour, 'horaire': horaire, 'classe': classe});
          }
        }
      }

      return seances;
    } catch (e) {
      rethrow;
    }
  }

  /// Compte le nombre de séances dans l'onglet "Séances"
  Future<int> getSeancesCount(String spreadsheetId) async {
    try {
      final sheetsApi = await getSheetsApi();
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Séances!A2:C',
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        return 0;
      }

      return values
          .where(
            (row) =>
                row.isNotEmpty &&
                row[0] != null &&
                row[0].toString().trim().isNotEmpty,
          )
          .length;
    } catch (e) {
      rethrow;
    }
  }

  /// Crée une nouvelle séance
  Future<void> createSeance({
    required String spreadsheetId,
    required String jour,
    required String horaire,
    required String classe,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Vérifier si l'onglet Séances existe
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheet = (spreadsheet.sheets ?? []).firstWhere(
        (s) => s.properties?.title == 'Séances',
        orElse: () => sheets_api.Sheet(),
      );

      if (sheet.properties?.title != 'Séances') {
        // Créer l'onglet Séances s'il n'existe pas
        await sheetsApi.spreadsheets.batchUpdate(
          sheets_api.BatchUpdateSpreadsheetRequest(
            requests: [
              sheets_api.Request(
                addSheet: sheets_api.AddSheetRequest(
                  properties: sheets_api.SheetProperties(
                    title: 'Séances',
                    gridProperties: sheets_api.GridProperties(
                      rowCount: 1,
                      columnCount: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          spreadsheetId,
        );

        // Ajouter les en-têtes
        await sheetsApi.spreadsheets.values.update(
          sheets_api.ValueRange(
            values: [
              ['Jour', 'Horaire', 'Classe'],
            ],
          ),
          spreadsheetId,
          'Séances!A1',
          valueInputOption: 'RAW',
        );
      }

      // Ajouter la nouvelle séance
      await sheetsApi.spreadsheets.values.append(
        sheets_api.ValueRange(
          values: [
            [jour, horaire, classe],
          ],
        ),
        spreadsheetId,
        'Séances!A2',
        valueInputOption: 'RAW',
        insertDataOption: 'INSERT_ROWS',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Met à jour une séance existante
  Future<void> updateSeance({
    required String spreadsheetId,
    required String oldJour,
    required String oldHoraire,
    required String oldClasse,
    required String newJour,
    required String newHoraire,
    required String newClasse,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Récupérer toutes les séances
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Séances!A2:C',
      );

      final values = response.values ?? [];
      int rowIndex = -1;

      // Trouver la ligne à mettre à jour
      for (var i = 0; i < values.length; i++) {
        final row = values[i];
        if (row.length >= 3 &&
            row[0].toString().trim() == oldJour &&
            row[1].toString().trim() == oldHoraire &&
            row[2].toString().trim() == oldClasse) {
          rowIndex =
              i + 2; // +2 car on commence à la ligne 2 (0-based + en-tête)
          break;
        }
      }

      if (rowIndex == -1) {
        throw Exception('Séance non trouvée pour la mise à jour');
      }

      // Mettre à jour la ligne
      await sheetsApi.spreadsheets.values.update(
        sheets_api.ValueRange(
          values: [
            [newJour, newHoraire, newClasse],
          ],
        ),
        spreadsheetId,
        'Séances!A$rowIndex',
        valueInputOption: 'RAW',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Supprime une séance
  Future<void> deleteSeance({
    required String spreadsheetId,
    required String jour,
    required String horaire,
    required String classe,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Récupérer les métadonnées du spreadsheet pour obtenir le sheetId de l'onglet Séances
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      int? seancesSheetId;

      for (var sheet in spreadsheet.sheets ?? []) {
        if (sheet.properties?.title == 'Séances') {
          seancesSheetId = sheet.properties?.sheetId;
          break;
        }
      }

      if (seancesSheetId == null) {
        throw Exception('Onglet Séances non trouvé dans le spreadsheet');
      }

      // Récupérer toutes les séances
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Séances!A2:C',
      );

      final values = response.values ?? [];
      int rowIndex = -1;

      // Trouver la ligne à supprimer
      for (var i = 0; i < values.length; i++) {
        final row = values[i];
        if (row.length >= 3 &&
            row[0].toString().trim() == jour &&
            row[1].toString().trim() == horaire &&
            row[2].toString().trim() == classe) {
          rowIndex =
              i + 2; // +2 car on commence à la ligne 2 (0-based + en-tête)
          break;
        }
      }

      if (rowIndex == -1) {
        throw Exception('Séance non trouvée pour la suppression');
      }

      // Supprimer la ligne
      await sheetsApi.spreadsheets.batchUpdate(
        sheets_api.BatchUpdateSpreadsheetRequest(
          requests: [
            sheets_api.Request(
              deleteDimension: sheets_api.DeleteDimensionRequest(
                range: sheets_api.DimensionRange(
                  sheetId: seancesSheetId,
                  dimension: 'ROWS',
                  startIndex: rowIndex - 1, // 0-based
                  endIndex: rowIndex, // L'index de fin est exclusif
                ),
              ),
            ),
          ],
        ),
        spreadsheetId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPointageDuJour(
    String spreadsheetId,
  ) async {
    try {
      final sheetsApi = await getSheetsApi();

      // 🔹 Lire les en-têtes depuis AD3:AK3
      final headerResp = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!AD3:AK3',
      );
      final headersRow = (headerResp.values ?? []).isNotEmpty
          ? headerResp.values!.first
          : [];
      final headers = headersRow
          .map((e) => e?.toString().trim() ?? '')
          .toList();

      if (headers.isEmpty) {
        return [];
      }

      int indexOf(String name) =>
          headers.indexWhere((h) => h.toLowerCase() == name.toLowerCase());

      final idxNumero = indexOf('N°');
      final idxNom = indexOf('Nom');
      final idxStatut = indexOf('Statut');
      final idxClasse = indexOf('Classe');
      final idxDate = indexOf('Date');
      final idxJour = indexOf('Jour');
      final idxHoraire = indexOf('Horaire');

      // 🔹 Lire les données à partir de AD4:AK
      final resp = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Pointage!AD4:AK',
      );
      final rows = resp.values ?? [];
      if (rows.isEmpty) {
        return [];
      }

      final pointages = <Map<String, dynamic>>[];
      for (final row in rows) {
        if (row.isEmpty ||
            row.every((c) => (c?.toString().trim().isEmpty ?? true))) {
          continue;
        }

        String cell(int i) =>
            (i >= 0 && i < row.length) ? row[i].toString().trim() : '';

        final item = <String, dynamic>{
          'N°': idxNumero >= 0 ? cell(idxNumero) : '',
          'Nom': idxNom >= 0 ? cell(idxNom) : '',
          'Statut': idxStatut >= 0 ? cell(idxStatut) : 'NON DÉFINI',
        };

        if (idxClasse >= 0) item['Classe'] = cell(idxClasse);
        if (idxDate >= 0) item['Date'] = cell(idxDate);
        if (idxJour >= 0) item['Jour'] = cell(idxJour);
        if (idxHoraire >= 0) item['Horaire'] = cell(idxHoraire);

        pointages.add(item);
      }

      return pointages;
    } catch (e) {
      rethrow;
    }
  }
}
