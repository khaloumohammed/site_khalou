import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'base_google_sheets_service.dart';

/// Service pour la gestion des critères dans Google Sheets
class CriteresService extends BaseGoogleSheetsService {
  CriteresService(super._authService);

  /// Récupère la liste de tous les critères
  Future<List<Map<String, String>>> getCriteres(String spreadsheetId) async {
    try {
      final sheetsApi = await getSheetsApi();

      await sheetsApi.spreadsheets.get(spreadsheetId);

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Critères!A2:A',
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        return [];
      }

      final criteres = <Map<String, String>>[];

      for (var i = 0; i < values.length; i++) {
        final row = values[i];
        if (row.isNotEmpty && row[0] != null) {
          final critere = row[0].toString().trim();
          if (critere.isNotEmpty) {
            criteres.add({'id': (i + 1).toString(), 'critere': critere});
          }
        }
      }

      return criteres;
    } catch (e) {
      rethrow;
    }
  }

  /// Écrit les paramètres de pointage dans la feuille de calcul
  Future<void> writePointageParameters({
    required String spreadsheetId,
    required List<List<dynamic>> parameters,
  }) async {
    try {
      final sheetsApi = await getSheetsApi();

      // Vérifier si l'onglet Pointage existe
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheetExists =
          spreadsheet.sheets?.any((s) => s.properties?.title == 'Pointage') ??
          false;

      if (!sheetExists) {
        // Créer l'onglet Pointage s'il n'existe pas
        await sheetsApi.spreadsheets.batchUpdate(
          sheets_api.BatchUpdateSpreadsheetRequest(
            requests: [
              sheets_api.Request(
                addSheet: sheets_api.AddSheetRequest(
                  properties: sheets_api.SheetProperties(
                    title: 'Pointage',
                    gridProperties: sheets_api.GridProperties(
                      rowCount: 100,
                      columnCount: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          spreadsheetId,
        );
      }

      // Écrire les paramètres dans la plage K2:O2

      final valueRange = sheets_api.ValueRange(values: parameters);

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        'Pointage!K2:O2',
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère une liste simple des critères (sans les IDs)
  Future<List<String>> getCriteresList(String spreadsheetId) async {
    try {
      final criteres = await getCriteres(spreadsheetId);
      return criteres
          .map((c) => c['critere'] ?? '')
          .where((c) => c.isNotEmpty)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Ajoute un nouveau critère
  Future<void> createCritere(String spreadsheetId, String critere) async {
    try {
      final sheetsApi = await getSheetsApi();

      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheetNames =
          spreadsheet.sheets
              ?.map((s) => s.properties?.title)
              .where((t) => t != null)
              .toList() ??
          [];

      if (!sheetNames.contains('Critères')) {
        throw Exception("Onglet 'Critères' non trouvé");
      }

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Critères!A:A',
      );

      final values = response.values;
      int targetRow = 2;

      if (values != null) {
        for (var i = 1; i < values.length; i++) {
          final row = values[i];
          if (row.isEmpty ||
              row[0] == null ||
              row[0].toString().trim().isEmpty) {
            targetRow = i + 1;
            break;
          }
          targetRow = i + 2;
        }
      }

      final range = 'Critères!A$targetRow:A$targetRow';
      final valueRange = sheets_api.ValueRange(
        values: [
          [critere],
        ],
      );

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'RAW',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Supprime un critère
  Future<void> deleteCritere(
    String spreadsheetId,
    String critereToDelete,
  ) async {
    try {
      final sheetsApi = await getSheetsApi();

      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheetNames =
          spreadsheet.sheets
              ?.map((s) => s.properties?.title)
              .where((t) => t != null)
              .toList() ??
          [];

      if (!sheetNames.contains('Critères')) {
        throw Exception("Onglet 'Critères' non trouvé");
      }

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Critères!A:A',
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        throw Exception("Aucun critère trouvé");
      }

      int targetRow = -1;
      for (var i = 1; i < values.length; i++) {
        final row = values[i];
        if (row.isNotEmpty && row[0] != null) {
          final currentCritere = row[0].toString().trim();
          if (currentCritere == critereToDelete) {
            targetRow = i + 1;
            break;
          }
        }
      }

      if (targetRow == -1) {
        throw Exception("Critère non trouvé");
      }

      // Effacer le contenu de la cellule au lieu de supprimer la ligne
      await sheetsApi.spreadsheets.values.clear(
        sheets_api.ClearValuesRequest(),
        spreadsheetId,
        'Critères!A$targetRow',
      );
    } catch (e) {
      rethrow;
    }
  }
}
