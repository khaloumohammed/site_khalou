// lib/config/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:attendance_app/core/services/auth_service.dart';
import 'package:attendance_app/presentation/screens/splash_screen.dart';
import 'package:attendance_app/presentation/screens/login_screen.dart';
import 'package:attendance_app/presentation/screens/sheet_selection_screen.dart';
import 'package:attendance_app/presentation/screens/menuprincipal_screen.dart';
import 'package:attendance_app/presentation/classes/classes_screen.dart';
import 'package:attendance_app/presentation/eleves/eleve_screen.dart';
import 'package:attendance_app/presentation/eleves/gestion_eleves_screen.dart';
import 'package:attendance_app/presentation/eleves/eleve_model.dart';
import 'package:attendance_app/presentation/seances/seances_screen.dart';
import 'package:attendance_app/presentation/items/items_screen.dart';

final GetIt _getIt = GetIt.instance;

/// Constantes des routes de l'application
class AppRoutes {
  AppRoutes._(); // Constructeur privé : classe utilitaire

  // Authentification
  static const String root = '/';
  static const String login = '/login';
  static const String sheetSelection = '/sheet-selection';
  static const String connectSheet = '/connectsheet';

  // Navigation principale
  static const String menuprincipal = '/menuprincipal';

  // Gestion des classes et élèves
  static const String classes = '/classes';
  static const String eleves = '/eleves';
  static const String gestionEleve = '/gestion-eleve';

  // Gestion des séances
  static const String gestionSeances = '/gestion-seances';
  static const String consultationSeances = '/consultation-seances';
  static const String pointageSeances = '/pointage-seances';

  // Items de pointage
  static const String itemsPointage = '/items-pointage';
}

/// Configuration du routeur GoRouter
final GoRouter router = GoRouter(
  initialLocation: AppRoutes.root,
  debugLogDiagnostics: false, // Désactivé en production
  routes: _buildRoutes(),
  redirect: _handleRedirection,
  errorBuilder: (context, state) => _buildErrorPage(context, state),
);

/// Construit la liste des routes
List<GoRoute> _buildRoutes() {
  return [
    // Authentification
    GoRoute(
      path: AppRoutes.root,
      name: 'root',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (_, __) => const LoginScreen(),
    ),

    // Sélection/Changement de feuille Google
    GoRoute(
      path: AppRoutes.sheetSelection,
      name: 'sheet-selection',
      builder: (_, __) => const SheetSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.connectSheet,
      name: 'connect-sheet',
      builder: (_, __) => const SheetSelectionScreen(),
    ),

    // Menu principal
    GoRoute(
      path: AppRoutes.menuprincipal,
      name: 'menu-principal',
      builder: (_, __) => const MenuPrincipalScreen(),
    ),

    // Classes & Élèves
    GoRoute(
      path: AppRoutes.classes,
      name: 'classes',
      builder: (_, __) => const ClassesScreen(),
    ),
    GoRoute(
      path: AppRoutes.eleves,
      name: 'eleves',
      builder: (_, state) => _buildElevesScreen(state),
    ),
    GoRoute(
      path: AppRoutes.gestionEleve,
      name: 'gestion-eleve',
      builder: (_, state) {
        final eleve = state.extra as Eleve?;
        return GestionElevesScreen(eleve: eleve);
      },
    ),

    // Séances
    GoRoute(
      path: AppRoutes.gestionSeances,
      name: 'gestion-seances',
      builder: (_, __) => const SeancesScreen(),
    ),
    GoRoute(
      path: AppRoutes.consultationSeances,
      name: 'consultation-seances',
      builder: (_, __) => const SeancesScreen(),
    ),
    GoRoute(
      path: AppRoutes.pointageSeances,
      name: 'pointage-seances',
      builder: (_, __) => const _PointageSeancesPlaceholder(),
    ),

    // Items de pointage
    GoRoute(
      path: AppRoutes.itemsPointage,
      name: 'items-pointage',
      builder: (_, __) => const ItemsScreen(),
    ),
  ];
}

/// Gère les redirections d'authentification
Future<String?> _handleRedirection(
  BuildContext context,
  GoRouterState state,
) async {
  try {
    final authService = _getIt<AuthService>();
    final isAuthenticated = await authService.isAuthenticated;
    final location = state.matchedLocation;

    const publicRoutes = <String>{AppRoutes.root, AppRoutes.login};

    // Rediriger les utilisateurs authentifiés loin de la page de connexion
    if (isAuthenticated && location == AppRoutes.login) {
      return AppRoutes.sheetSelection;
    }

    // Rediriger les utilisateurs non authentifiés vers la page de connexion
    if (!isAuthenticated && !publicRoutes.contains(location)) {
      return AppRoutes.login;
    }

    return null;
  } catch (e) {
    // Erreur silencieuse lors de la redirection
    return AppRoutes.root;
  }
}

/// Construit l'écran ElevesScreen avec les paramètres extraits
Widget _buildElevesScreen(GoRouterState state) {
  final extras = state.extra as Map<String, dynamic>?;
  final sheetId = extras?['sheetId'] as String? ?? '';
  final className = extras?['className'] as String? ?? '';
  return ElevesScreen(className: className, sheetId: sheetId);
}

/// Page d'erreur 404
Widget _buildErrorPage(BuildContext context, GoRouterState state) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text('Erreur'),
      backgroundColor: const Color(0xFF1E3A8A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _navigateBack(context),
      ),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 24),
            const Text(
              'Page introuvable',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            _buildErrorDetails(state),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.menuprincipal),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Retour au menu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Affiche les détails de l'erreur
Widget _buildErrorDetails(GoRouterState state) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          state.uri.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontFamily: 'monospace',
          ),
        ),
      ),
      if (state.error != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEF4444)),
          ),
          child: Text(
            'Détails: ${state.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
          ),
        ),
      ],
    ],
  );
}

/// Navigation arrière sécurisée
void _navigateBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.menuprincipal);
  }
}

/// Widget temporaire pour les séances de pointage
class _PointageSeancesPlaceholder extends StatelessWidget {
  const _PointageSeancesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pointage des Séances'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.menuprincipal),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_reg_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Pointage des Séances',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('À implémenter', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
