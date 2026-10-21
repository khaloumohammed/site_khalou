import 'dart:developer' as developer;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/spreadsheets',
  'https://www.googleapis.com/auth/drive.readonly',
];

// Client OAuth Web utilisé pour demander les jetons d'accès aux API Google.
const String googleServerClientId =
    '880183617539-2rvh8cf74a6dartmr9cbrj36t1leon37.apps.googleusercontent.com';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
    serverClientId: googleServerClientId,
  );

  /// Vérifie si l'utilisateur est actuellement connecté.
  Future<bool> get isAuthenticated async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  /// Tente de se reconnecter silencieusement avec timeout.
  Future<bool> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently().timeout(
        const Duration(seconds: 20),
        onTimeout: () => null,
      );
      return account != null;
    } catch (e) {
      return false;
    }
  }

  /// Connexion interactive via le bouton.
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 60),
        onTimeout: () => null,
      );
      if (account == null) {
        developer.log(
          'Connexion Google terminée sans compte sélectionné.',
          name: 'AuthService',
        );
        return false;
      }

      developer.log(
        'Compte Google sélectionné: ${account.email}',
        name: 'AuthService',
      );
      return true;
    } catch (error, stackTrace) {
      developer.log(
        'Échec de la connexion Google',
        name: 'AuthService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Fournit un client HTTP authentifié pour les appels Google API.
  Future<http.Client?> getAuthenticatedClient() async {
    try {
      final account = await _googleSignIn.signInSilently().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          developer.log(
            'signInSilently: timeout',
            name: 'AuthService',
          );
          return null;
        },
      );

      if (account == null) {
        developer.log(
          'signInSilently: aucun compte retourné (null)',
          name: 'AuthService',
        );
        return null;
      }

      final authHeaders = await account.authHeaders.timeout(
        const Duration(seconds: 20),
        onTimeout: () =>
            throw Exception('Timeout lors de la récupération des headers'),
      );

      return GoogleAuthClient(authHeaders);
    } catch (e, stackTrace) {
      developer.log(
        'getAuthenticatedClient: échec',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignorer les erreurs de déconnexion
    }
  }
}

/// Client HTTP enveloppant les requêtes avec les headers d'authentification Google.
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}
