import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// Classe de base pour les services Google Sheets
abstract class BaseGoogleSheetsService {
  final AuthService _authService;

  BaseGoogleSheetsService(this._authService);

  /// Obtient un client API Google Sheets authentifié
  Future<sheets_api.SheetsApi> getSheetsApi() async {
    final client = await _authService.getAuthenticatedClient();
    if (client == null) {
      throw Exception("Client non authentifié");
    }
    return sheets_api.SheetsApi(client);
  }

  /// Ferme le client HTTP de manière sécurisée
  Future<void> closeClient(http.Client? client) async {
    client?.close();
  }
}
