// lib/presentation/screens/menuprincipal_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/home/google_sheet_state.dart';
import 'package:attendance_app/presentation/widgets/app_drawer.dart';

/// Écran principal de navigation après connexion
class MenuPrincipalScreen extends StatelessWidget {
  const MenuPrincipalScreen({super.key});

  static const _primaryColor = Color(0xFF1E3A8A);
  static const _backgroundColor = Color(0xFFF0F4F8);
  static const _cardSpacing = 16.0;
  static const _topSpacing = 70.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSheetConnectedCard(context),
              const SizedBox(height: _topSpacing),
              _buildMenuCards(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la barre d'application
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _primaryColor,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const Text(
            'Menu Principal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  /// Construit la carte d'information de la feuille connectée
  Widget _buildSheetConnectedCard(BuildContext context) {
    return BlocBuilder<GoogleSheetCubit, SheetState>(
      builder: (context, state) {
        if (state is SheetConnected) {
          return _SheetInfoCard(
            sheetTitle: state.sheetTitle,
            sheetId: state.sheetId,
            isConnected: true,
            onChangePressed: () => _handleChangeSheet(context),
          );
        }

        return _SheetInfoCard(
          sheetTitle: 'Aucune feuille connectée',
          sheetId: '',
          isConnected: false,
          onChangePressed: () => _handleChangeSheet(context),
        );
      },
    );
  }

  /// Construit les cartes de menu
  Widget _buildMenuCards(BuildContext context) {
    return Column(
      children: [
        _MenuItemCard(
          icon: Icons.class_rounded,
          title: 'Gestion des classes',
          subtitle: 'Organiser les groupes d\'élèves',
          color: const Color(0xFFffc03c),
          onTap: () => context.go('/classes'),
        ),
        const SizedBox(height: _cardSpacing),
        _MenuItemCard(
          icon: Icons.event_available_rounded,
          title: 'Gestion des séances',
          subtitle: 'Créer et suivre les séances de pointage',
          color: const Color(0xFF3B82F6),
          onTap: () => context.go('/gestion-seances'),
        ),
        const SizedBox(height: _cardSpacing),
        _MenuItemCard(
          icon: Icons.checklist_rounded,
          title: 'Gestion des items de pointage',
          subtitle: 'Définir les critères de présence',
          color: const Color(0xFF10B981),
          onTap: () => context.go('/items-pointage'),
        ),
      ],
    );
  }

  /// Gère le changement de feuille Google
  void _handleChangeSheet(BuildContext context) {
    context.read<GoogleSheetCubit>().loadAvailableSheets();
    context.go('/connectsheet');
  }
}

/// Carte d'information de la feuille connectée
class _SheetInfoCard extends StatelessWidget {
  final String sheetTitle;
  final String sheetId;
  final bool isConnected;
  final VoidCallback onChangePressed;

  const _SheetInfoCard({
    required this.sheetTitle,
    required this.sheetId,
    required this.isConnected,
    required this.onChangePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? const Color(0xFFEEF2FF) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? const Color(0xFF6366F1) : Colors.grey,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            color: isConnected ? const Color(0xFF6366F1) : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sheetTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? const Color(0xFF1E3A8A) : Colors.grey,
                  ),
                ),
                if (isConnected)
                  Text(
                    'ID: $sheetId',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onChangePressed,
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Changer'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de menu individuelle
class _MenuItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItemCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.8),
      color,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }
}
