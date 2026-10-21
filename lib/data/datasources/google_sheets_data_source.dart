import 'package:attendance_app/core/services/auth_service.dart';
import 'package:googleapis/drive/v3.dart' as drive_api;
import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'package:http/http.dart' as http;
import 'package:attendance_app/data/models/spreadsheet_info.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

class GoogleSheetsDataSource extends ChangeNotifier {
  final AuthService _authService;

  GoogleSheetsDataSource(this._authService);

  /// Obtient une instance de l'API Google Sheets
  Future<sheets_api.SheetsApi> getSheetsApi() async {
    final client = await _authService.getAuthenticatedClient();
    if (client == null) {
      throw Exception("Impossible d'obtenir un client authentifié");
    }
    return sheets_api.SheetsApi(client);
  }

  /// Récupère la liste de toutes les feuilles de calcul Google.
  ///
  /// @returns Une Future contenant la liste des SpreadsheetInfo.
  /// @throws Exception si l'authentification échoue ou si l'API Drive renvoie une erreur.
  Future<List<SpreadsheetInfo>> getSpreadsheets() async {
    // Récupération du client avec timeout
    final http.Client? client = await _authService
        .getAuthenticatedClient()
        .timeout(const Duration(seconds: 25), onTimeout: () => null);

    if (client == null) {
      throw Exception(
        "L'utilisateur n'est pas authentifié. Veuillez vous reconnecter.",
      );
    }

    try {
      final driveApi = drive_api.DriveApi(client);

      // Appel de l'API avec timeout
      final fileList = await driveApi.files
          .list(
            q: "mimeType='application/vnd.google-apps.spreadsheet'",
            $fields: 'files(id, name)',
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception(
              "Délai d'attente dépassé lors de la récupération des feuilles",
            ),
          );

      final files = fileList.files;
      if (files == null || files.isEmpty) {
        return [];
      }

      // Mappage des objets
      final result = files
          .map((file) => SpreadsheetInfo(id: file.id!, title: file.name!))
          .toList();

      return result;
    } catch (e) {
      // Messages d'erreur plus clairs
      if (e.toString().contains("Délai d'attente")) {
        throw Exception(
          "Timeout: Impossible de contacter Google Drive. Vérifiez votre connexion.",
        );
      } else if (e.toString().contains("401")) {
        throw Exception("Session Google expirée. Veuillez vous reconnecter.");
      } else if (e.toString().contains("403")) {
        throw Exception(
          "Accès Google refusé (403). Vérifiez les autorisations du compte et les accès Google Drive/Sheets.",
        );
      } else {
        rethrow;
      }
    } finally {
      // Fermeture du client
      client.close();
    }
  }

  @override
  void dispose() {
    // La fermeture du client est gérée dans les méthodes qui l'utilisent
    super.dispose();
  }
}
