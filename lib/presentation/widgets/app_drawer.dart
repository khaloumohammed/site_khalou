import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // En-tête du drawer avec logo
          _buildDrawerHeader(),

          // Liste des items du menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Accueil',
                  route: '/menuprincipal',
                  color: const Color(0xFF1E3A8A),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildMenuItem(
                  context,
                  icon: Icons.class_rounded,
                  title: 'Gestion des classes',
                  route: '/classes',
                  color: const Color(0xFFffc03c),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.event_available_rounded,
                  title: 'Gestion des séances',
                  route: '/gestion-seances',
                  color: const Color(0xFF3B82F6),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.checklist_rounded,
                  title: 'Critères de pointage',
                  route: '/items',
                  color: const Color(0xFF10B981),
                ),
                const Divider(
                  height: 32,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                // Section À propos
                _buildAboutSection(context),

                const Divider(
                  height: 32,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
              ],
            ),
          ),

          // Section développeur en bas
          _buildDeveloperSection(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1 * 255),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Assiduité des élèves',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gestion de présence moderne',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9 * 255),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required Color color,
  }) {
    final isCurrentRoute = GoRouterState.of(context).uri.path == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentRoute
            ? const Color(0xFF1E3A8A).withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCurrentRoute
                ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isCurrentRoute ? const Color(0xFF1E3A8A) : color,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isCurrentRoute ? FontWeight.w700 : FontWeight.w600,
            color: isCurrentRoute
                ? const Color(0xFF0F172A)
                : const Color(0xFF1E293B),
          ),
        ),
        trailing: isCurrentRoute
            ? const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF1E3A8A),
                size: 24,
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          if (!isCurrentRoute) {
            context.go(route);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                const Text(
                  'À propos',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF3B82F6,
                      ).withValues(alpha: 0.1 * 255),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Fonctionnalités de l\'app',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E3A8A).withValues(alpha: 0.2 * 255),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1 * 255),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.code_rounded,
                  color: Color(0xFF1E3A8A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Développeur',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Application développée par Mohammed Boulhrouzi, enseignant d\'EPS au lycée Sidi Driss à Oujda, Maroc.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1 * 255),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Fonctionnalités',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeatureItem(
                icon: Icons.class_rounded,
                title: 'Gestion des classes',
                description:
                    'Organisez vos groupes d\'élèves par classe et niveau.',
                color: const Color(0xFFffc03c),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.event_available_rounded,
                title: 'Gestion des séances',
                description:
                    'Créez et planifiez vos séances de cours avec horaires et classes.',
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.checklist_rounded,
                title: 'Critères de pointage',
                description:
                    'Définissez vos propres critères : Présent, Absent, Retard, etc.',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.people_rounded,
                title: 'Gestion des élèves',
                description:
                    'Ajoutez, modifiez et gérez les informations de vos élèves.',
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.touch_app_rounded,
                title: 'Pointage rapide',
                description:
                    'Effectuez le pointage de présence en quelques secondes.',
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.cloud_sync_rounded,
                title: 'Synchronisation Google Sheets',
                description:
                    'Toutes vos données sont automatiquement sauvegardées dans Google Sheets.',
                color: const Color(0xFF06B6D4),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.history_rounded,
                title: 'Historique complet',
                description:
                    'Consultez l\'historique des pointages pour chaque élève.',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fermer',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15 * 255),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
