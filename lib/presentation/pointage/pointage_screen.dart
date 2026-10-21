// lib/presentation/pointage/pointage_screen.dart
// ignore_for_file: use_build_context_synchronously, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:attendance_app/core/services/auth_service.dart';
import 'package:attendance_app/core/services/eleves_service.dart';
import 'package:attendance_app/core/services/criteres_service.dart';
import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/home/google_sheet_state.dart';
import 'package:attendance_app/presentation/eleves/eleve_model.dart'
    as eleve_model;
import 'package:attendance_app/core/theme/app_colors.dart';

class PointageScreen extends StatefulWidget {
  final String seanceId;
  final String seanceTitre;
  final String classe;

  const PointageScreen({
    super.key,
    required this.seanceId,
    required this.seanceTitre,
    required this.classe,
  });

  @override
  State<PointageScreen> createState() => _PointageScreenState();
}

class _PointageScreenState extends State<PointageScreen> {
  late final ElevesService _elevesService;
  late final CriteresService _criteresService;

  final List<Map<String, dynamic>> _pendingPointages = [];
  bool _isSaving = false;
  int _expandedIndex = -1;

  // Palettes de couleurs
  static final List<Color> _cardColors = AppColors.cardBackgrounds;

  static final List<Color> _avatarColors = AppColors.cardPalette;

  late Future<List<eleve_model.Eleve>> _elevesFuture;

  @override
  void initState() {
    super.initState();
    _elevesService = ElevesService(AuthService());
    _criteresService = CriteresService(AuthService());
    _loadEleves();
  }

  /// Récupère le sheetId depuis le GoogleSheetCubit
  String? _getSheetId() {
    try {
      final state = context.read<GoogleSheetCubit>().state;
      if (state is SheetConnected) {
        return state.sheetId.isNotEmpty ? state.sheetId : null;
      }
    } catch (_) {}
    return null;
  }

  /// Charge les élèves de la classe
  void _loadEleves() {
    try {
      final sheetId = _getSheetId();
      if (sheetId == null || sheetId.isEmpty) {
        throw Exception('Non connecté à Google Sheets');
      }

      setState(() {
        _elevesFuture = _elevesService
            .getElevesByClasse(sheetId, widget.classe)
            .then((elevesList) => _mapToEleveModels(elevesList));
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur: $e');
      }
    }
  }

  /// Convertit les données en modèles Eleve
  List<eleve_model.Eleve> _mapToEleveModels(List<dynamic> elevesList) {
    return elevesList.map((eleveData) {
      return eleve_model.Eleve.fromJson({
        'id':
            eleveData['ID_Elève'] ??
            eleveData['ID_Élève'] ??
            eleveData['id'] ??
            '',
        'numero': eleveData['N°'] ?? eleveData['Numéro'] ?? '',
        'nom': eleveData['Nom'] ?? '',
        'classe': eleveData['Classe'] ?? widget.classe,
        'genre': eleveData['Genre'] ?? 'G',
        'naissance': eleveData['Naissance'] ?? '',
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_pendingPointages.isNotEmpty) _buildSaveButton(),
          Expanded(child: _buildElevesList()),
        ],
      ),
    );
  }

  /// Construit la barre d'application
  PreferredSizeWidget _buildAppBar() {
    final parts = widget.seanceTitre.split(' - ');
    final jour = parts.isNotEmpty ? parts[0].trim() : '';
    final horaire = parts.length > 1 ? parts[1].trim() : '';

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 20),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
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
              color: Color(0xFF1E3A8A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pointage',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            if (jour.isNotEmpty || horaire.isNotEmpty)
              Text(
                '$jour - $horaire',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              tooltip: 'Recharger',
              onPressed: _loadEleves,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le bouton d'enregistrement
  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            blurRadius: 16,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSaving ? null : _saveAllPointages,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.cloud_upload_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSaving
                            ? 'Enregistrement...'
                            : 'Enregistrer les pointages',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_pendingPointages.length} élève(s)',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit la liste des élèves
  Widget _buildElevesList() {
    return FutureBuilder<List<eleve_model.Eleve>>(
      future: _elevesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun élève trouvé'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: List.generate(
              snapshot.data!.length,
              (index) => _buildEleveCard(snapshot.data![index], index),
            ),
          ),
        );
      },
    );
  }

  /// État d'erreur
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadEleves,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  /// Construit la carte d'un élève
  Widget _buildEleveCard(eleve_model.Eleve eleve, int index) {
    final isExpanded = _expandedIndex == index;
    final cardColor = _cardColors[index % _cardColors.length];
    final avatarColor = _avatarColors[index % _avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColor, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey('eleve_${index}_$isExpanded'),
          initiallyExpanded: isExpanded,
          maintainState: true,
          onExpansionChanged: (expanded) =>
              setState(() => _expandedIndex = expanded ? index : -1),
          leading: _buildAvatar(eleve, avatarColor),
          title: Text(
            eleve.nom,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: const Color(0xFF1E293B),
            ),
          ),
          subtitle: Text(
            'N°${eleve.numero}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isExpanded
                  ? const Color(0xFFDBEAFE)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF475569),
            ),
          ),
          children: [
            const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Ligne 1: 4 boutons (3 items rapides + Plus)
                  Row(
                    children: [
                      // Bouton Présent
                      Expanded(
                        child: _buildQuickActionButton(
                          'Présent',
                          Icons.check_circle_rounded,
                          const Color(0xFF10B981),
                          () => _quickPointage(eleve, 'Présent'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Bouton Absent
                      Expanded(
                        child: _buildQuickActionButton(
                          'Absent',
                          Icons.cancel_rounded,
                          const Color(0xFFEF4444),
                          () => _quickPointage(eleve, 'Absent'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Bouton Retard
                      Expanded(
                        child: _buildQuickActionButton(
                          'Retard',
                          Icons.schedule_rounded,
                          const Color(0xFFF59E0B),
                          () => _quickPointage(eleve, 'Retard'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Bouton Plus
                      Expanded(
                        child: _buildActionButton(
                          'Plus',
                          Icons.more_horiz_rounded,
                          const Color(0xFF64748B),
                          () => _showPointageDialog(eleve, avatarColor),
                          isCompact: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Ligne 2: Boutons Historique et Statistiques
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Historique',
                          Icons.history_rounded,
                          const Color(0xFF1E3A8A),
                          () => _showHistoriquePointage(eleve.id, eleve.nom),
                          isSmall: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Statistiques',
                          Icons.bar_chart_rounded,
                          const Color(0xFF10B981),
                          () => _showStatisticsDialog(eleve.id, eleve.nom),
                          isSmall: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit l'avatar d'un élève
  Widget _buildAvatar(eleve_model.Eleve eleve, Color color) {
    // Déterminer l'image selon le genre
    final genre = eleve.genre.toUpperCase();
    final avatarPath = (genre == "F")
        ? "assets/images/avatar_f.png"
        : "assets/images/avatar_g.png";

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: ClipOval(
        child: Image.asset(
          avatarPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback en cas d'erreur de chargement
            return Center(
              child: Text(
                eleve.nom.isNotEmpty ? eleve.nom[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construit un bouton d'action
  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isSmall = false, // Pour les boutons de la ligne 2
    bool isCompact = false, // Pour le bouton Plus sur la ligne 1
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isSmall ? 16 : (isCompact ? 14 : 18)),
      label: Text(
        label,
        style: TextStyle(fontSize: isSmall ? 12 : (isCompact ? 13 : 14)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : (isSmall ? 12 : 16),
          vertical: isCompact ? 8 : (isSmall ? 8 : 12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
        ),
        textStyle: isSmall
            ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)
            : (isCompact
                  ? const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)
                  : const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  /// Construit un bouton de pointage rapide
  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        shadowColor: color.withValues(alpha: 0.3),
      ),
    );
  }

  /// Affiche le dialogue de pointage
  Future<void> _showPointageDialog(eleve_model.Eleve eleve, Color color) async {
    final sheetId = _getSheetId();
    if (sheetId == null) {
      _showErrorSnackBar('Non connecté');
      return;
    }

    try {
      final criteres = await _criteresService.getCriteres(sheetId);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => _PointageDialog(
          eleve: eleve,
          criteres: criteres,
          themeColor: color,
          onConfirm: (selected) {
            _updatePresence(eleve, selected);
            setState(() => _expandedIndex = -1);
          },
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  /// Pointage rapide pour les items fréquents
  void _quickPointage(eleve_model.Eleve eleve, String critere) {
    _updatePresence(eleve, [critere]);
    setState(() => _expandedIndex = -1);
  }

  /// Met à jour la présence
  void _updatePresence(eleve_model.Eleve eleve, List<String> criteres) {
    final now = DateTime.now();
    _pendingPointages.add({
      'eleve': eleve,
      'criteres': criteres,
      'date': DateFormat('dd/MM/yyyy').format(now),
      'heure': DateFormat('HH:mm').format(now),
    });
    _showSuccessSnackBar('${eleve.nom} pointé(e)');
  }

  /// Enregistre tous les pointages
  Future<void> _saveAllPointages() async {
    if (_pendingPointages.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final sheetId = _getSheetId();
      if (sheetId == null) throw Exception('Non connecté');

      // Extraire jour et horaire du titre de la séance
      final parts = widget.seanceTitre.split(' - ');
      final jour = parts.isNotEmpty ? parts[0].trim() : '';
      final horaire = parts.length > 1 ? parts[1].trim() : '';

      // Préparer les lignes à insérer dans Google Sheets
      final rows = <List<dynamic>>[];

      for (final pointage in _pendingPointages) {
        final eleve = pointage['eleve'] as eleve_model.Eleve;
        final criteres = pointage['criteres'] as List<String>;
        final date = pointage['date'] as String;

        // Déterminer le statut (premier critère sélectionné ou "Present" par défaut)
        final statut = criteres.isNotEmpty ? criteres.first : 'Present';

        // Format des colonnes : N°, Nom, Classe, Jour, Horaire, Date, Statut, ID_Élève
        rows.add([
          eleve.numero, // N°
          eleve.nom, // Nom
          widget.classe, // Classe
          jour, // Jour
          horaire, // Horaire
          date, // Date
          statut, // Statut
          eleve.id, // ID_Élève
        ]);
      }

      // Enregistrer dans Google Sheets
      await _elevesService.appendPointagesBatch(
        spreadsheetId: sheetId,
        rows: rows,
      );

      setState(() {
        _pendingPointages.clear();
        _isSaving = false;
      });
      _showSuccessSnackBar('${rows.length} pointage(s) enregistré(s) !');
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      _showErrorSnackBar('Erreur: $e');
    }
  }

  /// Affiche les statistiques de pointage d'un élève
  Future<void> _showStatisticsDialog(String eleveId, String eleveNom) async {
    final sheetId = _getSheetId();
    if (sheetId == null) {
      _showErrorSnackBar('Non connecté');
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Statistiques de $eleveNom'),
        content: const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      // Récupérer l'historique de l'élève
      final historique = await _elevesService.getHistoriquePointageDirect(
        spreadsheetId: sheetId,
        eleveId: eleveId,
      );

      if (!mounted) return;

      // Fermer l'indicateur de chargement
      Navigator.pop(context);

      // Calculer les statistiques
      final Map<String, int> stats = {};
      for (final entry in historique) {
        final statut = entry.length > 3 ? entry[3] : '';
        if (statut.isNotEmpty) {
          stats[statut] = (stats[statut] ?? 0) + 1;
        }
      }

      // Afficher les statistiques
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistiques de pointage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                eleveNom,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          content: historique.isEmpty
              ? const Text('Aucun pointage enregistré pour le moment')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Total des pointages
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF1E3A8A),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total des pointages',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${historique.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Liste des statistiques par statut
                    ...stats.entries.map((entry) {
                      final statut = entry.key;
                      final count = entry.value;
                      final percentage = (count / historique.length * 100)
                          .toStringAsFixed(1);
                      final color = _getStatusColor(statut);

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color, width: 1),
                        ),
                        child: Row(
                          children: [
                            // Nombre d'occurrences à la place de l'icône
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Détails du statut
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    statut,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                  Text(
                                    '$count occurrence${count > 1 ? 's' : ''} ($percentage%)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Suppression du badge du nombre
                          ],
                        ),
                      );
                    }),
                  ],
                ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer l'indicateur de chargement
        _showErrorSnackBar('Erreur: ${e.toString()}');
      }
    }
  }

  /// Retourne l'icône selon le statut
  // ignore: unused_element
  IconData _getStatusIcon(String statut) {
    switch (statut.toLowerCase()) {
      case 'présent':
      case 'present':
        return Icons.check_circle_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      case 'retard':
        return Icons.schedule_rounded;
      default:
        return Icons.help_rounded;
    }
  }

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

  /// Affiche l'historique
  /// Affiche une boîte de confirmation pour supprimer un pointage
  Future<void> _showDeleteConfirmation(
    BuildContext context, {
    required String eleveId,
    required String eleveNom,
    required String date,
    required String jour,
    required String horaire,
    required String statut,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer la suppression'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voulez-vous vraiment supprimer ce pointage ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Élève: $eleveNom',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('Date: $date'),
                  Text('Séance: $jour $horaire'),
                  Text('Statut: $statut'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette action est irréversible.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    // Si l'utilisateur a confirmé
    if (confirmed == true) {
      await _performDelete(
        context,
        eleveId: eleveId,
        date: date,
        jour: jour,
        horaire: horaire,
      );
    }
  }

  /// Effectue la suppression réelle du pointage
  Future<void> _performDelete(
    BuildContext context, {
    required String eleveId,
    required String date,
    required String jour,
    required String horaire,
  }) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final sheetCubit = context.read<GoogleSheetCubit>();
      final sheetId = await sheetCubit.getSpreadsheetId();

      if (sheetId != null) {
        final success = await _elevesService.deletePointage(
          spreadsheetId: sheetId,
          eleveId: eleveId,
          date: date,
          jour: jour,
          horaire: horaire,
        );

        if (!mounted) return;

        // Fermer l'indicateur de chargement
        Navigator.of(context).pop();

        if (success) {
          // Message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pointage supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          // Fermer l'historique et rafraîchir
          Navigator.of(context).pop(); // Fermer l'historique
          _loadEleves(); // Rafraîchir les données
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la suppression du pointage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Fermer l'indicateur de chargement s'il est ouvert
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showHistoriquePointage(String eleveId, String eleveNom) async {
    final sheetId = _getSheetId();
    if (sheetId == null) {
      _showErrorSnackBar('Non connecté');
      return;
    }

    final parts = widget.seanceTitre.split(' - ');
    final jourSeance = parts.isNotEmpty ? parts[0].trim() : '';
    final horaireSeance = parts.length > 1 ? parts[1].trim() : '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Historique de $eleveNom'),
        content: const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      // Utiliser la méthode directe pour diagnostic
      final historique = await _elevesService.getHistoriquePointageDirect(
        spreadsheetId: sheetId,
        eleveId: eleveId,
        classe: widget.classe,
        jour: jourSeance,
        horaire: horaireSeance,
      );

      // Alternative: essayer la méthode originale si la directe ne fonctionne pas
      // final historique = await _elevesService.getHistoriquePointage(
      //   spreadsheetId: sheetId,
      //   eleveId: eleveId,
      // );

      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Historique de $eleveNom'),
          content: historique.isEmpty
              ? const Text('Aucun historique pour le moment')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: historique.length,
                    itemBuilder: (context, index) {
                      final entry = historique[index];
                      final date = entry.isNotEmpty ? entry[0] : '';
                      final jour = entry.length > 1 ? entry[1] : '';
                      final horaire = entry.length > 2 ? entry[2] : '';
                      final statut = entry.length > 3 ? entry[3] : '';

                      Color statutColor = Colors.grey;
                      if (statut.toLowerCase().contains('présent')) {
                        statutColor = const Color(0xFF10B981);
                      } else if (statut.toLowerCase().contains('absent')) {
                        statutColor = const Color(0xFFEF4444);
                      } else if (statut.toLowerCase().contains('retard')) {
                        statutColor = const Color(0xFFF59E0B);
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            '$jour $date',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            horaire,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statutColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: statutColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  statut,
                                  style: TextStyle(
                                    color: statutColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Bouton de suppression
                              InkWell(
                                onTap: () => _showDeleteConfirmation(
                                  context,
                                  eleveId: eleveId,
                                  eleveNom: eleveNom,
                                  date: date,
                                  jour: jour,
                                  horaire: horaire,
                                  statut: statut,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnackBar(
        'Erreur: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}',
      );
    }
  }

  // SnackBars
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
}

// Dialogue de pointage
class _PointageDialog extends StatefulWidget {
  final eleve_model.Eleve eleve;
  final List<Map<String, String>> criteres;
  final Color themeColor;
  final Function(List<String>) onConfirm;

  const _PointageDialog({
    required this.eleve,
    required this.criteres,
    required this.themeColor,
    required this.onConfirm,
  });

  @override
  State<_PointageDialog> createState() => _PointageDialogState();
}

class _PointageDialogState extends State<_PointageDialog> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.themeColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              'Pointage de ${widget.eleve.nom}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: widget.criteres.length,
              itemBuilder: (context, index) {
                final critere = widget.criteres[index]['critere'] ?? '';
                return CheckboxListTile(
                  value: _selected.contains(critere),
                  onChanged: (value) => setState(
                    () => value!
                        ? _selected.add(critere)
                        : _selected.remove(critere),
                  ),
                  title: Text(critere),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onConfirm(_selected.toList());
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
