import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:attendance_app/config/app_router.dart';
import 'package:attendance_app/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = GetIt.I<AuthService>();
  bool _isLoading = false;

  // Connexion interactive via le bouton
  void _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final success = await _authService.signIn();
      if (!mounted) return;

      if (success) {
        // GoRouter redirigera vers /home lorsque l'utilisateur sera authentifié.
        _navigateToHome();
        return;
      }

      setState(() => _isLoading = false);
      _showSignInError(
        'Aucun compte Google n’a été sélectionné. Réessayez. Si cela se reproduit après avoir choisi un compte, vérifiez la configuration OAuth de cette version de l’application.',
      );
    } on PlatformException catch (error, stackTrace) {
      developer.log(
        'Échec de la connexion Google (${error.code})',
        name: 'AuthService',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;

      setState(() => _isLoading = false);
      final message = switch (error.code) {
        'sign_in_failed' =>
          'Google a refusé la connexion. Vérifiez la configuration OAuth et le certificat SHA-1 de cette version.',
        'network_error' =>
          'Connexion Google impossible. Vérifiez votre accès Internet puis réessayez.',
        _ => 'Erreur Google (${error.code}). Vérifiez la configuration OAuth.',
      };
      _showSignInError(message);
    } catch (error, stackTrace) {
      developer.log(
        'Échec de la connexion Google',
        name: 'AuthService',
        error: error,
        stackTrace: stackTrace,
      );
      debugPrint('GOOGLE SIGN-IN ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showSignInError('Impossible de se connecter à Google. Réessayez.');
    }
  }

  void _showSignInError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToHome() {
    // Naviguer vers la root. GoRouter interceptera et redirigera vers /home.
    // C'est la manière la plus sûre de déclencher le système de redirection d'Auth.
    context.go(AppRoutes.root);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo avec animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Image.asset(
                    'assets/logo.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                // Titre
                const Text(
                  'Authentification Enseignant',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  "Connectez-vous pour accéder à votre feuille de présence Google Sheets.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                if (_isLoading)
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF1E3A8A),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Connexion en cours...',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  // Bouton de connexion Google moderne
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF1E3A8A,
                          ).withValues(alpha: 0.2 * 255),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _handleSignIn,
                      icon: const Icon(Icons.login_rounded, size: 22),
                      label: const Text(
                        'Se connecter avec Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
