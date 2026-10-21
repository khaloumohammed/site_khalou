import 'package:attendance_app/presentation/seances/seances_cubit.dart';
import 'package:attendance_app/presentation/seances/seances_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/core/services/eleves_service.dart';
import 'package:attendance_app/data/models/seance_model.dart';
import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/home/google_sheet_state.dart';
import 'package:attendance_app/presentation/pointage/pointage_screen.dart';

class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});

  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Map<String, bool> _expandedDays = {};
  final TextEditingController _searchController = TextEditingController();
  late ElevesService _elevesService;
  bool _isLoadingAbsents = false;
  bool _showOnlyAbsents = false; // Variable pour le filtre des absents

  /// Retourne la couleur selon le statut
  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'présent':
      case 'present':
        return const Color(0xFF10B981);
      case 'absent':
        return const Color(0xFFEF4444);
      case 'retard':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  void initState() {
    super.initState();

    // Récupérer les services depuis GoogleSheetCubit
    final googleSheetCubit = context.read<GoogleSheetCubit>();
    _elevesService = googleSheetCubit.elevesService;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _searchController.addListener(() {
      setState(() {});
    });

    _loadSeancesIfConnected();
  }

  void _loadSeancesIfConnected() {
    final sheetCubit = context.read<GoogleSheetCubit>();
    final sheetState = sheetCubit.state;

    if (sheetState is SheetConnected) {
      _loadSeancesFromSheet(sheetState);
    }
  }

  Future<void> _loadSeancesFromSheet(SheetConnected state) async {
    try {
      final sessionCubit = context.read<SessionCubit>();
      await sessionCubit.loadSeances(state.sheetId);
    } catch (e) {
      if (mounted) {
        _showError('Erreur lors du chargement des séances: $e');
      }
    }
  }

  Future<void> _refresh() async {
    final sheetCubit = context.read<GoogleSheetCubit>();
    final sheetState = sheetCubit.state;

    if (sheetState is SheetConnected) {
      await _loadSeancesFromSheet(sheetState);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleDayExpansion(String day) {
    setState(() {
      _expandedDays[day] = !(_expandedDays[day] ?? false);
    });
  }

  void _runDiagnostics() {
    // Implémentez la logique de diagnostic ici
  }

  String _formatDayHeader(String dateString) {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final parsedDate = dateFormat.parse(dateString);
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      bool sameDate(DateTime a, DateTime b) {
        return a.year == b.year && a.month == b.month && a.day == b.day;
      }

      if (sameDate(parsedDate, today)) {
        return 'Aujourd\'hui';
      } else if (sameDate(parsedDate, yesterday)) {
        return 'Hier';
      } else if (sameDate(parsedDate, tomorrow)) {
        return 'Demain';
      } else {
        return DateFormat('EEEE d MMMM y', 'fr_FR').format(parsedDate);
      }
    } catch (e) {
      return dateString;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFEF4444),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF1E3A8A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Rechercher dans les séances (jour, horaire, classe...)',
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          context.read<SessionCubit>().searchSeances('');
                        },
                      )
                    : null,
              ),
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 15),
              onChanged: (q) => context.read<SessionCubit>().searchSeances(q),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF1E3A8A),
            ),
            onPressed: () => context.go('/menuprincipal'),
            tooltip: 'Retour',
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        title: const Text(
          'Séances',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 22,
                    color: Color(0xFF475569),
                  ),
                  tooltip: 'Actualiser',
                  onPressed: _refresh,
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Diagnostic',
                  onPressed: _runDiagnostics,
                  icon: const Icon(
                    Icons.analytics_rounded,
                    color: Color(0xFF475569),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          BlocListener<GoogleSheetCubit, SheetState>(
            listener: (context, sheetState) {
              if (sheetState is SheetConnected) {
                _loadSeancesFromSheet(sheetState);
              }
            },
            child: const SizedBox.shrink(),
          ),
          _buildSearchBar(),
          Expanded(
            child: BlocConsumer<SessionCubit, SessionState>(
              listener: (context, state) {
                if (state is SessionError) {
                  _showError(state.message);
                }
              },
              builder: (context, state) {
                if (state is SessionLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SessionLoaded) {
                  final seances = state.seances;

                  if (seances.isEmpty) {
                    return _buildEmptyState();
                  }

                  final Map<String, List<SeanceModel>> seancesByDate = {};
                  for (var seance in seances) {
                    final date = seance.jour;
                    if (!seancesByDate.containsKey(date)) {
                      seancesByDate[date] = [];
                    }
                    seancesByDate[date]!.add(seance);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: seancesByDate.length,
                    itemBuilder: (context, index) {
                      final date = seancesByDate.keys.elementAt(index);
                      final seancesForDate = seancesByDate[date]!;
                      final isExpanded = _expandedDays[date] ?? true;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _toggleDayExpansion(date),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              margin: const EdgeInsets.only(
                                top: 8,
                                left: 16,
                                right: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _formatDayHeader(date),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: const Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 8),
                            ...seancesForDate.map(
                              (seance) => _buildSeanceCard(seance),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      );
                    },
                  );
                } else {
                  return _buildEmptyState();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddSeanceDialog,
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildSeanceCard(SeanceModel seance) {
    final isExpanded = _expandedDays['seance_${seance.id}'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedDays['seance_${seance.id}'] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF1E3A8A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seance.horaire,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              seance.jour,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF86EFAC),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      seance.classe,
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: const Color(0xFF64748B),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Ligne 1: Pointage + Aujourd'hui
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PointageScreen(
                                  seanceId: seance.id,
                                  seanceTitre:
                                      '${seance.jour} - ${seance.horaire}',
                                  classe: seance.classe,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Pointage',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showAbsentsList(seance, todayOnly: true),
                          icon: const Icon(Icons.today_rounded, size: 18),
                          label: const Text(
                            'Aujourd\'hui',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF16A34A),
                            side: const BorderSide(
                              color: Color(0xFF86EFAC),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Ligne 2: Historique pointage
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAbsentsList(seance),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text(
                        'Historique pointage',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(
                          color: Color(0xFFFECACA),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Ligne 3: Modifier + Supprimer
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditDialog(seance),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text(
                            'Modifier',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            side: const BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteDialog(seance),
                          icon: const Icon(Icons.delete_rounded, size: 18),
                          label: const Text(
                            'Supprimer',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditDialog(SeanceModel seance) {
    final jourController = TextEditingController(text: seance.jour);
    final horaireController = TextEditingController(text: seance.horaire);
    final classeController = TextEditingController(text: seance.classe);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Modifier la séance',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jourController,
              decoration: const InputDecoration(
                labelText: 'Jour',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: horaireController,
              decoration: const InputDecoration(
                labelText: 'Horaire',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: classeController,
              decoration: const InputDecoration(
                labelText: 'Classe',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<SessionCubit>().updateSeance(
                  seance.id,
                  jour: jourController.text,
                  horaire: horaireController.text,
                  classe: classeController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _showSuccess('Séance modifiée avec succès');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _showError('Erreur lors de la modification: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(SeanceModel seance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Supprimer la séance',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer la séance "${seance.jour} - ${seance.horaire}" pour la classe ${seance.classe} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<SessionCubit>().deleteSeance(seance.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  _showSuccess('Séance supprimée avec succès');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _showError('Erreur lors de la suppression: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAddSeanceDialog() {
    String? selectedJour;
    final joursDelaSemaine = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    final horaireController = TextEditingController();
    final classeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Ajouter une séance',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedJour,
                  decoration: const InputDecoration(
                    labelText: 'Jour',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  items: joursDelaSemaine.map((jour) {
                    return DropdownMenuItem(value: jour, child: Text(jour));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedJour = value;
                    });
                  },
                  validator: (value) => value == null ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: horaireController,
                  decoration: const InputDecoration(
                    labelText: 'Horaire (ex: 08:00-09:00)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: classeController,
                  decoration: const InputDecoration(
                    labelText: 'Classe (ex: 1BACSEF-1)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_rounded),
                  ),
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
                if (selectedJour == null ||
                    horaireController.text.isEmpty ||
                    classeController.text.isEmpty) {
                  _showError('Veuillez remplir tous les champs');
                  return;
                }
                try {
                  await context.read<SessionCubit>().addSeance(
                    jour: selectedJour!,
                    horaire: horaireController.text,
                    classe: classeController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    _showSuccess('Séance ajoutée avec succès');
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    _showError('Erreur lors de l\'ajout: $e');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
              ),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 40,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune séance trouvée',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Les séances apparaîtront ici une fois que vous serez connecté à Google Sheets et que vous aurez des données à afficher.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Actualiser',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher l'historique complet d'une séance
  /// Affiche l'historique de tous les pointages d'une séance dans une boîte de dialogue
  Future<void> _showAbsentsList(
    SeanceModel seance, {
    bool todayOnly = false,
  }) async {
    if (_isLoadingAbsents) return;
    setState(() => _isLoadingAbsents = true);

    try {
      final sheetCubit = context.read<GoogleSheetCubit>();
      final sheetState = sheetCubit.state;

      if (sheetState is! SheetConnected) {
        throw Exception('Non connecté à Google Sheets');
      }

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
          ),
        ),
      );

      // 1. Extraire les informations de la séance
      final dateFormat = DateFormat('dd/MM/yyyy');
      final todayDate = dateFormat.format(DateTime.now());

      // Utiliser directement les attributs de la séance
      final jour = seance.jour;
      final horaire = seance.horaire;

      // 2. Charger les données selon le type de vue demandé
      // - todayOnly=true  -> pointages de la séance du jour
      // - todayOnly=false -> tout l'historique de la classe
      final pointagesData = todayOnly
          ? await _elevesService.getPointagesBySeanceFlexible(
              spreadsheetId: sheetState.sheetId,
              classe: seance.classe,
              jour: jour,
              horaire: horaire,
            )
          : await _elevesService.getPointagesByClasseFlexible(
              spreadsheetId: sheetState.sheetId,
              classe: seance.classe,
            );

      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer l'indicateur de chargement

      // Filtrer les pointages de la séance pour aujourd'hui (si demandé)
      final pointagesFiltered = todayOnly
          ? pointagesData.where((p) {
              final date = (p['Date'] ?? '').trim();
              return date == todayDate;
            }).toList()
          : pointagesData;

      // 3. Filtrer pour compter uniquement les vrais absents
      final absentsData = pointagesFiltered.where((p) {
        final statut = (p['Statut'] ?? '').toLowerCase().trim();
        return statut == 'absent'; // Uniquement les absents, pas les retards
      }).toList();

      // 4. Afficher les résultats
      if (pointagesFiltered.isEmpty) {
        _showSnackBar(
          'Aucun pointage',
          todayOnly
              ? 'Aucun pointage trouvé aujourd\'hui pour cette séance !'
              : 'Aucun pointage trouvé pour cette classe !',
          Colors.green,
        );
        return;
      }

      _showOnlyAbsents = false;

      // 5. Afficher la boîte de dialogue avec l'historique complet de la séance
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historique de la séance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (todayOnly) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Détails d\'aujourd\'hui',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  todayOnly
                      ? '${seance.classe} - $jour $horaire'
                      : '${seance.classe} - Toutes les séances',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${pointagesFiltered.length} pointage${pointagesFiltered.length > 1 ? 's' : ''} (${absentsData.length} absent${absentsData.length > 1 ? 's' : ''})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height *
                      0.6, // 60% de la hauteur de l'écran
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Filtre pour afficher uniquement les absents
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _showOnlyAbsents = !_showOnlyAbsents;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _showOnlyAbsents
                                      ? const Color(
                                          0xFFEF4444,
                                        ).withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _showOnlyAbsents
                                        ? const Color(0xFFEF4444)
                                        : Colors.grey.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _showOnlyAbsents
                                          ? Icons.filter_alt_rounded
                                          : Icons.filter_alt_outlined,
                                      size: 16,
                                      color: _showOnlyAbsents
                                          ? const Color(0xFFEF4444)
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _showOnlyAbsents
                                          ? 'Absents uniquement (${absentsData.length})'
                                          : 'Tous les pointages (${pointagesFiltered.length})',
                                      style: TextStyle(
                                        color: _showOnlyAbsents
                                            ? const Color(0xFFEF4444)
                                            : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Liste des pointages scrollable
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: false,
                        itemCount: _showOnlyAbsents
                            ? absentsData.length
                            : pointagesFiltered.length,
                        itemBuilder: (context, index) {
                          final pointage = _showOnlyAbsents
                              ? absentsData[index]
                              : pointagesFiltered[index];
                          final nom = pointage['Nom'] ?? '';
                          final statut = pointage['Statut'] ?? 'Présent';
                          final numeroEleve = pointage['N°'] ?? '${index + 1}';
                          final date = pointage['Date'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(
                                  statut,
                                ).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // N° de l'élève
                                    Container(
                                      width: 32,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          statut,
                                        ).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          numeroEleve,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: _getStatusColor(statut),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Nom de l'élève
                                    Expanded(
                                      child: Text(
                                        nom.trim(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF1E293B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Statut
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          statut,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _getStatusColor(statut),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        statut,
                                        style: TextStyle(
                                          color: _getStatusColor(statut),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (date.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date: $date',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bouton pour fermer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAbsents = false);
      }
    }
  }

  /// Widget helper pour afficher une ligne d'information
  // ignore: unused_element
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // Affiche un message temporaire
  void _showSnackBar(String title, String message, Color color) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // Méthode pour afficher les critères de pointage dans une boîte de dialogue
  // ignore: unused_element
  void _showCriteriaDialog(SeanceModel seance) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(now);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text('Critères de pointage'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCriteriaItem('Classe', seance.classe),
              const SizedBox(height: 8),
              _buildCriteriaItem('Jour', seance.jour),
              const SizedBox(height: 8),
              _buildCriteriaItem('Horaire', seance.horaire),
              const SizedBox(height: 8),
              _buildCriteriaItem('Date', formattedDate),
              const SizedBox(height: 8),
              _buildCriteriaItem('Critère', 'Absent', isImportant: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCriteriaItem(
    String label,
    String value, {
    bool isImportant = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label :',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isImportant
                ? const Color(0xFFDC2626)
                : const Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isImportant
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF475569),
              fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
