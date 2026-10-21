// lib/presentation/screens/sheet_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:attendance_app/config/app_router.dart';
import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/home/google_sheet_state.dart';
import 'package:attendance_app/data/models/spreadsheet_info.dart';

/// Écran de sélection d'une feuille Google Sheets
class SheetSelectionScreen extends StatelessWidget {
  const SheetSelectionScreen({super.key});

  static const _primaryColor = Color(0xFF1E3A8A);
  static const _accentColor = Color(0xFF6366F1);
  static const _backgroundColor = Color(0xFFF0F4F8);
  static const _errorColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context),
      body: BlocListener<GoogleSheetCubit, SheetState>(
        listener: (context, state) {
          if (state is SheetConnected) {
            context.go(AppRoutes.menuprincipal);
          }
        },
        child: BlocBuilder<GoogleSheetCubit, SheetState>(
          builder: (context, state) => _buildBody(context, state),
        ),
      ),
    );
  }

  /// Construit la barre d'application
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: _primaryColor,
      title: const Text(
        'Sélection de la feuille',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.go(AppRoutes.login),
      ),
      centerTitle: true,
    );
  }

  /// Construit le corps principal en fonction de l'état
  Widget _buildBody(BuildContext context, SheetState state) {
    if (state is SheetLoading || state is SheetInitial) {
      return _buildLoadingView();
    }

    if (state is SheetError) {
      return _buildErrorView(context, state);
    }

    if (state is SheetSelection) {
      return _buildSheetList(context, state.availableSheets);
    }

    return _buildErrorView(context, const SheetError('État inconnu'));
  }

  /// Vue de chargement
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des feuilles...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// Vue d'erreur
  Widget _buildErrorView(BuildContext context, SheetError error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: _errorColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _errorColor, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final cubit = context.read<GoogleSheetCubit>();
                if (error.requiresReauthentication) {
                  cubit.reconnect();
                } else {
                  cubit.loadAvailableSheets();
                }
              },
              icon: Icon(
                error.requiresReauthentication
                    ? Icons.login_rounded
                    : Icons.refresh_rounded,
              ),
              label: Text(
                error.requiresReauthentication ? 'Se reconnecter' : 'Réessayer',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Liste des feuilles disponibles
  Widget _buildSheetList(BuildContext context, List<SpreadsheetInfo> sheets) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        _buildHeaderCard(sheets.length),
        const SizedBox(height: 24),
        ...sheets.map((sheet) => _buildSheetCard(context, sheet)),
      ],
    );
  }

  /// En-tête informatif
  Widget _buildHeaderCard(int sheetCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentColor, width: 1.2),
      ),
      child: Column(
        children: [
          const Icon(Icons.table_chart_rounded, size: 48, color: _accentColor),
          const SizedBox(height: 12),
          const Text(
            'Sélectionnez une feuille',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$sheetCount feuille(s) disponible(s)',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  /// Carte d'une feuille
  Widget _buildSheetCard(BuildContext context, SpreadsheetInfo sheet) {
    return GestureDetector(
      onTap: () =>
          context.read<GoogleSheetCubit>().selectSheet(sheet.id, sheet.title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFEEF2FF),
          border: Border.all(color: _accentColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.description_rounded,
              color: _accentColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sheet.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${_truncateId(sheet.id)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: _accentColor,
            ),
          ],
        ),
      ),
    );
  }

  /// Tronque l'ID pour l'affichage
  String _truncateId(String id) {
    const maxLength = 20;
    if (id.length > maxLength) {
      return '${id.substring(0, maxLength)}...';
    }
    return id;
  }
}
