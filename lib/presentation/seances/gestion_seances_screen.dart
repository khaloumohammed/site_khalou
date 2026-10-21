// lib/presentation/seances/gestion_seances_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:attendance_app/config/app_router.dart';
import 'package:attendance_app/presentation/seances/seances_cubit.dart';
import 'package:attendance_app/presentation/seances/seances_state.dart';
import 'package:attendance_app/presentation/seances/seance_model.dart';
import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/home/google_sheet_state.dart';

/// Écran de gestion des séances
class GestionSeancesScreen extends StatefulWidget {
  const GestionSeancesScreen({super.key});

  @override
  State<GestionSeancesScreen> createState() => _GestionSeancesScreenState();
}

class _GestionSeancesScreenState extends State<GestionSeancesScreen> {
  late final TextEditingController _searchController;
  bool _isSearchMode = false;

  static const _primaryColor = Color(0xFF1E3A8A);
  static const _accentColor = Color(0xFF3B82F6);
  static const _errorColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadSeancesIfConnected();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Charge les séances si une feuille est connectée
  void _loadSeancesIfConnected() {
    Future.microtask(() {
      if (!mounted) return;
      final sheetState = context.read<GoogleSheetCubit>().state;
      if (sheetState is SheetConnected) {
        _loadSeancesFromSheet(sheetState.sheetId);
      }
    });
  }

  /// Charge les séances depuis la feuille Google
  Future<void> _loadSeancesFromSheet(String sheetId) async {
    try {
      final seancesCubit = context.read<SessionCubit>();
      seancesCubit.setSpreadsheetId(sheetId);
      await seancesCubit.loadSeances(sheetId);
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          BlocListener<GoogleSheetCubit, SheetState>(
            listener: (context, state) {
              if (state is SheetConnected) {
                _loadSeancesFromSheet(state.sheetId);
              }
            },
            child: const SizedBox.shrink(),
          ),
          Expanded(
            child: BlocBuilder<SessionCubit, SessionState>(
              builder: (context, state) => _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la barre d'application
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: _isSearchMode
          ? TextField(
              controller: _searchController,
              onChanged: (query) =>
                  context.read<SessionCubit>().filterByExactDay(query),
              decoration: InputDecoration(
                hintText: 'Rechercher par jour...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            )
          : const Text(
              'Gestion des Séances',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _primaryColor,
          ),
          onPressed: () => context.go(AppRoutes.menuprincipal),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearchMode ? Icons.close_rounded : Icons.search_rounded,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _isSearchMode = !_isSearchMode;
              if (!_isSearchMode) {
                _searchController.clear();
                context.read<SessionCubit>().showAllSeances();
              }
            });
          },
        ),
      ],
    );
  }

  /// Construit le corps de l'écran en fonction de l'état
  Widget _buildBody(SessionState state) {
    if (state is SessionLoading) {
      return _buildLoadingView();
    }

    if (state is SessionError) {
      return _buildErrorView(state.message);
    }

    if (state is SessionLoaded) {
      final seances = state.seances.cast<SeanceModel>();
      return seances.isEmpty ? _buildEmptyView() : _buildSeancesList(seances);
    }

    return _buildInitialView();
  }

  /// Vue de chargement
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withValues(alpha: 0.1),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chargement des séances...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Vue d'erreur
  Widget _buildErrorView(String message) {
    return _buildCenteredEmptyState(
      icon: Icons.error_outline_rounded,
      iconColor: _errorColor,
      title: 'Erreur de chargement',
      subtitle: message,
      buttonLabel: 'Réessayer',
      onButtonTap: _loadSeancesIfConnected,
    );
  }

  /// Vue initial (aucune séance)
  Widget _buildInitialView() {
    return _buildCenteredEmptyState(
      icon: Icons.schedule_rounded,
      iconColor: Colors.grey,
      title: 'Aucune séance disponible',
      subtitle: 'Connectez-vous à une feuille Google Sheets',
      buttonLabel: 'Retour à l\'accueil',
      onButtonTap: () => context.go(AppRoutes.menuprincipal),
    );
  }

  /// Vue vide (après recherche)
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucune séance trouvée',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune séance ne correspond à ce jour',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// État centré réutilisable
  Widget _buildCenteredEmptyState({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onButtonTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 56, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onButtonTap,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
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

  /// Liste des séances
  Widget _buildSeancesList(List<SeanceModel> seances) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.build_rounded,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Outils de Gestion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCrudButton(
                    'Consulter',
                    Icons.visibility_rounded,
                    Colors.orange.shade600,
                    () {},
                  ),
                  _buildCrudButton(
                    'Créer',
                    Icons.add_rounded,
                    Colors.orange.shade500,
                    _showCreateDialog,
                  ),
                  _buildCrudButton(
                    'Modifier',
                    Icons.edit_rounded,
                    Colors.orange.shade400,
                    _showEditDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: seances.length,
            itemBuilder: (_, i) => _buildSeanceCard(seances[i]),
          ),
        ),
      ],
    );
  }

  /// Bouton CRUD
  Widget _buildCrudButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// Carte de séance
  Widget _buildSeanceCard(SeanceModel seance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showSeanceDetails(seance),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.orange.withValues(alpha: 0.15),
                Colors.orange.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seance.classe,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${seance.jour} - ${seance.horaire}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Affiche les détails d'une séance
  void _showSeanceDetails(SeanceModel seance) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Séance - ${seance.classe}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Classe:', seance.classe),
            const SizedBox(height: 12),
            _buildDetailRow('Jour:', seance.jour),
            const SizedBox(height: 12),
            _buildDetailRow('Horaire:', seance.horaire),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Ligne de détail
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  /// Dialogue de création d'une nouvelle séance
  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => _buildSimpleDialog(
        'Créer une nouvelle séance',
        'Fonctionnalité à implémenter',
      ),
    );
  }

  /// Dialogue de modification d'une séance
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (_) => _buildSimpleDialog(
        'Modifier une séance',
        'Fonctionnalité à implémenter',
      ),
    );
  }

  /// Dialogue simple réutilisable
  AlertDialog _buildSimpleDialog(String title, String content) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
