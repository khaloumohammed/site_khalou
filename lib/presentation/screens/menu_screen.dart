import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:attendance_app/config/app_router.dart';
import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/home/google_sheet_state.dart';
import 'package:attendance_app/data/models/seance_model.dart';
import 'package:attendance_app/presentation/seances/seances_cubit.dart';
import 'package:attendance_app/presentation/seances/seances_state.dart';

class MenuPrincipalScreen extends StatelessWidget {
  const MenuPrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Gestion des Présences',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: () =>
                context.read<GoogleSheetCubit>().loadAvailableSheets(),
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.black87),
            onPressed: () => _signOut(context),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: BlocListener<GoogleSheetCubit, SheetState>(
        listener: _sheetStateListener,
        child: BlocBuilder<GoogleSheetCubit, SheetState>(
          builder: (context, state) {
            // Rediriger vers sélection si pas connecté à une feuille
            if (state is! SheetConnected) {
              Future.microtask(() {
                if (context.mounted) {
                  context.go(AppRoutes.sheetSelection);
                }
              });
              return _buildLoadingView();
            }

            // Afficher le dashboard principal si feuille connectée
            return _buildMainDashboard(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMainDashboard(BuildContext context, SheetConnected state) {
    final cubit = context.read<GoogleSheetCubit>();
    final seancesCubit = context.read<SessionCubit>();

    // Définir le spreadsheetId dans le cubit des séances
    seancesCubit.setSpreadsheetId(state.sheetId);

    return MultiBlocProvider(
      providers: [BlocProvider.value(value: seancesCubit)],
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildActiveSheetCard(context, state, cubit),
          ),
          SliverToBoxAdapter(child: _buildCrudToolsSection(context)),
          SliverToBoxAdapter(child: _buildSeancesByDaySection(context, state)),
          SliverToBoxAdapter(child: _buildStatisticsSection(context, cubit)),
        ],
      ),
    );
  }

  Widget _buildActiveSheetCard(
    BuildContext context,
    SheetConnected state,
    GoogleSheetCubit cubit,
  ) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSheetDetails(context, state),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feuille Active',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.sheetTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => cubit.disconnectSheet(),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Changer de feuille'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  void _sheetStateListener(BuildContext context, SheetState state) {
    if (state is SheetConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connecté à: ${state.sheetTitle}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSheetDetails(BuildContext context, SheetConnected state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la feuille'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${state.sheetTitle}'),
            const SizedBox(height: 8),
            Text('ID: ${state.sheetId}', style: const TextStyle(fontSize: 12)),
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

  void _signOut(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction de déconnexion à implémenter')),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    switch (route) {
      case '/classes':
        context.go('${AppRoutes.menuprincipal}/${AppRoutes.classes}');
        break;
      case '/seances':
        context.go(
          '${AppRoutes.menuprincipal}/${AppRoutes.consultationSeances}',
        );
        break;
      case '/criteres':
        context.go('${AppRoutes.menuprincipal}/${AppRoutes.itemsPointage}');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation vers $route (à implémenter)'),
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }

  Widget _buildCrudToolsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build_rounded, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'Outils de Gestion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCrudButton(
                context,
                icon: Icons.add_rounded,
                label: 'Créer',
                color: Colors.blue.shade600,
                onTap: () => _showCreateDialog(context),
              ),
              _buildCrudButton(
                context,
                icon: Icons.visibility_rounded,
                label: 'Consulter',
                color: Colors.blue.shade500,
                onTap: () => _navigateTo(context, '/seances'),
              ),
              _buildCrudButton(
                context,
                icon: Icons.edit_rounded,
                label: 'Modifier',
                color: Colors.blue.shade400,
                onTap: () => _showEditDialog(context),
              ),
              _buildCrudButton(
                context,
                icon: Icons.delete_rounded,
                label: 'Supprimer',
                color: Colors.blue.shade300,
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCrudButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: color.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final seancesCubit = context.read<SessionCubit>();
    final jourCtrl = TextEditingController();
    final horaireCtrl = TextEditingController();
    final classeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Créer une nouvelle séance'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: jourCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jour',
                  hintText: 'Ex: Lundi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: horaireCtrl,
                decoration: const InputDecoration(
                  labelText: 'Horaire',
                  hintText: 'Ex: 09:00 - 10:30',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: classeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Classe',
                  hintText: 'Ex: Terminale A',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              // Capturer context avant l'async
              final navigator = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(context);

              // Attendre l'opération asynchrone
              await seancesCubit.addSeance(
                jour: jourCtrl.text.trim(),
                horaire: horaireCtrl.text.trim(),
                classe: classeCtrl.text.trim(),
              );

              // Vérifier que le widget existe toujours
              if (context.mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Séance créée')),
                );
              }

              // Nettoyer les contrôleurs
              jourCtrl.dispose();
              horaireCtrl.dispose();
              classeCtrl.dispose();
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier une séance'),
        content: const Text(
          'Fonctionnalité à implémenter - Sélectionnez une séance d\'abord',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer une séance'),
        content: const Text(
          'Fonctionnalité à implémenter - Sélectionnez une séance d\'abord',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.red),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeancesByDaySection(BuildContext context, SheetConnected state) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, seancesState) {
        if (seancesState is! SessionLoaded) {
          return Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200, width: 1),
            ),
            child: const Center(child: Text('Chargement des séances...')),
          );
        }

        final seances = seancesState.seances;
        final groupedSeances = _groupSeancesByDay(seances);

        return Container(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Emploi du temps hebdomadaire',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._buildDayExpansionTiles(context, groupedSeances),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<SeanceModel>> _groupSeancesByDay(List<SeanceModel> seances) {
    final daysOrder = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
    ];
    final grouped = <String, List<SeanceModel>>{};

    for (var day in daysOrder) {
      grouped[day] = [];
    }

    for (var seance in seances) {
      final day = seance.jour.trim();
      if (grouped.containsKey(day)) {
        grouped[day]!.add(seance);
      } else {
        grouped[day] = [seance];
      }
    }

    for (var day in grouped.keys) {
      grouped[day]!.sort((a, b) => a.horaire.compareTo(b.horaire));
    }

    return grouped;
  }

  List<Widget> _buildDayExpansionTiles(
    BuildContext context,
    Map<String, List<SeanceModel>> groupedSeances,
  ) {
    final daysOrder = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
    ];
    final blueShades = [
      Colors.blue.shade100,
      Colors.blue.shade200,
      Colors.blue.shade300,
      Colors.blue.shade400,
      Colors.blue.shade500,
      Colors.blue.shade600,
    ];

    return daysOrder.map<Widget>((day) {
      final seances = groupedSeances[day] ?? [];
      final dayIndex = daysOrder.indexOf(day);
      final tileColor = blueShades[dayIndex % blueShades.length];

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tileColor.withValues(alpha: 0.5), width: 1),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor: tileColor.withValues(alpha: 0.1),
            collapsedBackgroundColor: tileColor.withValues(alpha: 0.05),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    day.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tileColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${seances.length}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            children: seances.isEmpty
                ? [
                    Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: Text(
                        'Aucune séance programmée',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ]
                : [
                    ...seances.map(
                      (seance) => _buildSeanceTile(context, seance, tileColor),
                    ),
                    _buildDayCrudTools(context, day, tileColor),
                  ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSeanceTile(
    BuildContext context,
    SeanceModel seance,
    Color dayColor,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: dayColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.schedule_rounded, color: dayColor, size: 20),
      ),
      title: Text(
        seance.classe,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        seance.horaire,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleSeanceAction(context, value, seance),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility, size: 18),
                SizedBox(width: 8),
                Text('Voir détails'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('Modifier'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Supprimer', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      onTap: () => _showSeanceDetailsDialog(context, seance),
    );
  }

  Widget _buildDayCrudTools(BuildContext context, String day, Color dayColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: dayColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dayColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSmallCrudButton(
            context,
            icon: Icons.add,
            label: 'Ajouter',
            color: dayColor,
            onTap: () => _showCreateDialog(context),
          ),
          _buildSmallCrudButton(
            context,
            icon: Icons.edit,
            label: 'Modifier',
            color: dayColor.withValues(alpha: 0.8),
            onTap: () => _showEditDialog(context),
          ),
          _buildSmallCrudButton(
            context,
            icon: Icons.delete,
            label: 'Supprimer',
            color: Colors.red.shade400,
            onTap: () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCrudButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSeanceAction(
    BuildContext context,
    String action,
    SeanceModel seance,
  ) {
    switch (action) {
      case 'view':
        _showSeanceDetailsDialog(context, seance);
        break;
      case 'edit':
        _showEditDialog(context);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showSeanceDetailsDialog(BuildContext context, SeanceModel seance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Séance - ${seance.classe}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Classe:', seance.classe),
            const SizedBox(height: 8),
            _buildDetailRow('Jour:', seance.jour),
            const SizedBox(height: 8),
            _buildDetailRow('Horaire:', seance.horaire),
            const SizedBox(height: 8),
            _buildDetailRow('ID:', seance.id),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildStatisticsSection(BuildContext context, GoogleSheetCubit cubit) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Statistiques',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                icon: Icons.class_rounded,
                label: 'Classes',
                value: cubit.classCount.toString(),
                color: Colors.white.withValues(alpha: 0.9),
              ),
              _buildStatCard(
                icon: Icons.event_note_rounded,
                label: 'Séances',
                value: cubit.seancesCount.toString(),
                color: Colors.white.withValues(alpha: 0.9),
              ),
              _buildStatCard(
                icon: Icons.checklist_rounded,
                label: 'Critères',
                value: cubit.criteresCount.toString(),
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
