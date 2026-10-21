import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:attendance_app/core/services/auth_service.dart';
import 'package:attendance_app/data/models/spreadsheet_info.dart';

class GoogleSheetsClient {
  final AuthService _authService;

  GoogleSheetsClient(this._authService);

  /// 🔍 Récupère la liste des feuilles Google accessibles par l'utilisateur
  Future<List<SpreadsheetInfo>> getSpreadsheets() async {
    final http.Client? client = await _authService.getAuthenticatedClient();

    if (client == null) {
      throw Exception(
        "Utilisateur non authentifié ou échec de l'obtention du client.",
      );
    }

    try {
      final driveApi = drive.DriveApi(client);

      final fileList = await driveApi.files.list(
        q: "mimeType='application/vnd.google-apps.spreadsheet' and trashed=false",
        $fields: 'files(id, name)',
        pageSize: 50,
      );

      return fileList.files
              ?.map((file) => SpreadsheetInfo(id: file.id!, title: file.name!))
              .toList() ??
          [];
    } catch (e) {
      throw Exception(
        "Erreur lors de la récupération des feuilles Google : $e",
      );
    } finally {
      client.close();
    }
  }

  /// 📄 Récupère les données d’un onglet spécifique dans une feuille
  Future<List<List<String>>> getSheetData(
    String sheetId,
    String sheetName,
  ) async {
    final http.Client? client = await _authService.getAuthenticatedClient();

    if (client == null) {
      throw Exception("Client non authentifié.");
    }

    try {
      final sheetsApi = sheets.SheetsApi(client);
      final response = await sheetsApi.spreadsheets.values.get(
        sheetId,
        sheetName,
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        return [];
      }

      return values
          .map((row) => row.map((cell) => cell.toString()).toList())
          .toList();
    } catch (e) {
      throw Exception("Erreur lors de la lecture de la feuille : $e");
    } finally {
      client.close();
    }
  }

  /// 📝 (à venir) Méthode pour écrire ou modifier des données dans la feuille
  /// Exemple : ajouter un élève, modifier une ligne, etc.
  /// Future<void> updateSheetData(...) { ... }
}
