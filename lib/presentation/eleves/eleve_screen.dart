import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/domain/entities/attendance_eleve.dart';
import 'package:attendance_app/core/theme/app_colors.dart';
import 'package:attendance_app/core/utils/date_input_formatter.dart';
import 'eleve_cubit.dart';
import 'eleve_state.dart';

class ElevesScreen extends StatefulWidget {
  final String className;
  final String sheetId;

  const ElevesScreen({
    super.key,
    required this.className,
    required this.sheetId,
  });

  @override
  State<ElevesScreen> createState() => _ElevesScreenState();
}

class _ElevesScreenState extends State<ElevesScreen> {
  int expandedIndex = -1;
  String _filter = "Tout";

  @override
  void initState() {
    super.initState();
    context.read<ElevesCubit>().fetchEleves(widget.sheetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05 * 255),
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
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          child: Text(
            "Élèves - ${widget.className}",
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1 * 255),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              tooltip: 'Recharger',
              onPressed: () =>
                  context.read<ElevesCubit>().fetchEleves(widget.sheetId),
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (scaffoldContext) {
          return BlocConsumer<ElevesCubit, ElevesState>(
            listener: (context, state) {
              if (state is ElevesError) {
                _showSnackBar(
                  scaffoldContext,
                  state.message,
                  const Color(0xFFEF4444),
                  Icons.error_outline_rounded,
                );
              } else if (state is ElevesOperationSuccess) {
                _showSnackBar(
                  scaffoldContext,
                  state.message,
                  const Color(0xFF10B981),
                  Icons.check_circle_rounded,
                );
              }
            },
            builder: (context, state) {
              // Gérer l'état de chargement initial
              if (state is ElevesLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                );
              }

              // Récupérer les élèves depuis l'état approprié
              List<AttendanceEleve> allEleves = [];
              if (state is ElevesLoaded) {
                allEleves = state.eleves;
              } else if (state is ElevesOperationLoading) {
                // Continuer d'afficher les élèves pendant l'opération
                allEleves = state.currentEleves;
              }

              if (allEleves.isNotEmpty) {
                final eleves = allEleves
                    .where((e) => e.classe.trim() == widget.className.trim())
                    .toList();

                // Si aucun élève trouvé pour cette classe
                if (eleves.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun élève dans la classe ${widget.className}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Appuyez sur + pour ajouter un élève',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Appliquer filtre
                List<AttendanceEleve> filtered = eleves;
                if (_filter == "F") {
                  filtered = eleves
                      .where((e) => e.genre.toUpperCase() == "F")
                      .toList();
                } else if (_filter == "G") {
                  filtered = eleves.where((e) {
                    final g = e.genre.toUpperCase();
                    return g == "G" || g == "M"; // Support pour M et G
                  }).toList();
                }

                return CustomScrollView(
                  slivers: [
                    // Carte Statistiques
                    SliverToBoxAdapter(
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Total: ${eleves.length}",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Filles: ${eleves.where((e) => e.genre.toUpperCase() == 'F').length}",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Garçons: ${eleves.where((e) {
                                    final g = e.genre.toUpperCase();
                                    return g == 'G' || g == 'M';
                                  }).length}",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Sticky header pour filtres
                    SliverAppBar(
                      pinned: true,
                      elevation: 0,
                      backgroundColor: const Color(0xFFF0F4F8),
                      automaticallyImplyLeading: false,
                      toolbarHeight: 56,
                      flexibleSpace: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: Text(
                                "Tout",
                                style: TextStyle(
                                  color: _filter == "Tout"
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: _filter == "Tout",
                              selectedColor: const Color(0xFF1E3A8A),
                              backgroundColor: Colors.white,
                              onSelected: (_) =>
                                  setState(() => _filter = "Tout"),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(
                                "Filles",
                                style: TextStyle(
                                  color: _filter == "F"
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: _filter == "F",
                              selectedColor: const Color(0xFFEC4899),
                              backgroundColor: Colors.white,
                              onSelected: (_) => setState(() => _filter = "F"),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(
                                "Garçons",
                                style: TextStyle(
                                  color: _filter == "G"
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: _filter == "G",
                              selectedColor: const Color(0xFF3B82F6),
                              backgroundColor: Colors.white,
                              onSelected: (_) => setState(() => _filter = "G"),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bouton modification multi-élèves
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openBulkEdit,
                            icon: const Icon(
                              Icons.format_list_numbered_rounded,
                              size: 20,
                            ),
                            label: const Text(
                              'Modification multi-élèves (N°)',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Liste des élèves
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final eleve = filtered[index];
                        return _buildEleveCard(eleve, index, scaffoldContext);
                      }, childCount: filtered.length),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                );
              }

              // État par défaut (pendant les transitions)
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Ajouter',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEleveCard(
    AttendanceEleve eleve,
    int index,
    BuildContext scaffoldContext,
  ) {
    final genre = eleve.genre.toUpperCase();
    final avatarPath = (genre == "F")
        ? "assets/images/avatar_f.png"
        : "assets/images/avatar_g.png";

    final colorPalette = AppColors.cardPalette;
    final itemColor = colorPalette[index % colorPalette.length];

    return Card(
      // Clé stable basée sur l'ID de l'élève: évite que Flutter réutilise
      // par erreur l'Element (et son état/animation ExpansionTile) d'un
      // autre élève lorsque la liste change d'ordre (ex: après une
      // modification de N° en masse qui change le tri).
      key: ValueKey(eleve.id),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: itemColor.withValues(alpha: 0.4),
            width: 1.2,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: expandedIndex == index,
            onExpansionChanged: (expanded) {
              setState(() {
                expandedIndex = expanded ? index : -1;
              });
            },
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            childrenPadding: const EdgeInsets.only(
              bottom: 16,
              left: 16,
              right: 16,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: itemColor.withValues(alpha: 0.1),
              child: ClipOval(
                child: Image.asset(
                  avatarPath,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback avec initiale en cas d'erreur
                    return Center(
                      child: Text(
                        eleve.nom.isNotEmpty ? eleve.nom[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: itemColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            title: Text(
              eleve.nom,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: itemColor.withValues(alpha: 0.9),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "N°: ${eleve.numero} | Genre: ${eleve.genre} | Naissance: ${eleve.naissance}",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.expand_more_rounded,
                color: itemColor,
                size: 22,
              ),
            ),
            children: [
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _buildCRUDActionButton(
                      icon: Icons.edit_rounded,
                      label: 'Modifier',
                      color: const Color(0xFF3B82F6),
                      onTap: () => _showEditDialog(context, eleve),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCRUDActionButton(
                      icon: Icons.delete_rounded,
                      label: 'Supprimer',
                      color: const Color(0xFFEF4444),
                      onTap: () =>
                          _showDeleteConfirmation(scaffoldContext, eleve),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog de confirmation de suppression
  void _showDeleteConfirmation(
    BuildContext scaffoldContext,
    AttendanceEleve eleve,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Confirmer la suppression",
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Êtes-vous sûr de vouloir supprimer cet élève ?",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eleve.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "N°: ${eleve.numero} | Classe: ${eleve.classe}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Cette action est irréversible.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFFFBFB),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Annuler",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ElevesCubit>().deleteEleveMethod(
                widget.sheetId,
                eleve.id,
              );
              setState(() => expandedIndex = -1);
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODIFIÉ ---
  void _showAddDialog(BuildContext context) {
    final nomController = TextEditingController();
    final numeroController = TextEditingController();
    final genreController = TextEditingController();
    final naissanceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          "Ajouter un élève",
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        // AJOUTÉ: StatefulBuilder pour gérer l'état localement
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter localSetState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: numeroController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "N°",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nomController,
                    decoration: const InputDecoration(
                      labelText: "Nom",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Genre',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // MODIFIÉ: Style personnalisé supprimé pour hériter du thème
                      ChoiceChip(
                        label: const Text("Fille"),
                        selected: genreController.text.toUpperCase() == 'F',
                        onSelected: (_) {
                          // MODIFIÉ: Utilise localSetState
                          localSetState(() {
                            genreController.text = 'F';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      // MODIFIÉ: Style personnalisé supprimé pour hériter du thème
                      ChoiceChip(
                        label: const Text("Garçon"),
                        selected: genreController.text.toUpperCase() == 'G',
                        onSelected: (_) {
                          // MODIFIÉ: Utilise localSetState
                          localSetState(() {
                            genreController.text = 'G';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: naissanceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [DateInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: "Naissance",
                      border: OutlineInputBorder(),
                      hintText: "JJ/MM/AAAA",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF8FAFC),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final numero = numeroController.text.trim();
                final nom = nomController.text.trim();
                final genre = genreController.text.trim().toUpperCase();
                final naissance = naissanceController.text.trim();
                final classe = widget.className;

                // Génération de l'ID unique: classe_numero (format standardisé)
                final id = "${classe}_$numero";

                context.read<ElevesCubit>().createEleveMethod(widget.sheetId, {
                  'id': id, // ID explicite au format classe_numero
                  'numero': numero,
                  'nom': nom,
                  'classe': classe,
                  'genre': genre,
                  'naissance': naissance,
                });
                setState(() => expandedIndex = -1);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  // --- MODIFICATION MULTI-ÉLÈVES ---
  void _openBulkEdit() {
    final cubit = context.read<ElevesCubit>();
    final state = cubit.state;
    final all = state is ElevesLoaded
        ? state.eleves
        : state is ElevesOperationLoading
        ? state.currentEleves
        : <AttendanceEleve>[];
    final eleves = all
        .where((e) => e.classe.trim() == widget.className.trim())
        .toList();
    if (eleves.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _BulkEditDialog(
        cubit: cubit,
        sheetId: widget.sheetId,
        classe: widget.className,
        eleves: eleves,
      ),
    );
  }

  // --- MODIFIÉ ---
  void _showEditDialog(BuildContext context, AttendanceEleve eleve) {
    final nomController = TextEditingController(text: eleve.nom);
    final numeroController = TextEditingController(text: eleve.numero);
    final genreController = TextEditingController(text: eleve.genre);
    final naissanceController = TextEditingController(text: eleve.naissance);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          "Modifier l'élève",
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        // AJOUTÉ: StatefulBuilder pour gérer l'état localement
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter localSetState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: numeroController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "N°",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nomController,
                    decoration: const InputDecoration(
                      labelText: "Nom",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Genre',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text(
                          "Fille",
                          style: TextStyle(
                            color: genreController.text.toUpperCase() == 'F'
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: genreController.text.toUpperCase() == 'F',
                        selectedColor: const Color(0xFFEC4899),
                        backgroundColor: Colors.white,
                        onSelected: (_) {
                          localSetState(() {
                            genreController.text = 'F';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(
                          "Garçon",
                          style: TextStyle(
                            color:
                                (genreController.text.toUpperCase() == 'G' ||
                                    genreController.text.toUpperCase() == 'M')
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected:
                            (genreController.text.toUpperCase() == 'G' ||
                            genreController.text.toUpperCase() == 'M'),
                        selectedColor: const Color(0xFF3B82F6),
                        backgroundColor: Colors.white,
                        onSelected: (_) {
                          localSetState(() {
                            genreController.text = 'G';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: naissanceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [DateInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: "Naissance",
                      border: OutlineInputBorder(),
                      hintText: "JJ/MM/AAAA",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF8FAFC),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context
                    .read<ElevesCubit>()
                    .updateEleveMethod(widget.sheetId, eleve.id, {
                      'numero': numeroController.text.trim(),
                      'nom': nomController.text.trim(),
                      'classe': widget.className,
                      'genre': genreController.text.trim().toUpperCase(),
                      'naissance': naissanceController.text.trim(),
                    });
                setState(() => expandedIndex = -1);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    BuildContext scaffoldContext,
    String message,
    Color bgColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
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
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildCRUDActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialogue de modification multi-élèves (N°).
// Implémenté comme un vrai StatefulWidget (et non des variables locales dans
// une fonction) afin que les TextEditingController soient créés dans
// initState() et détruits dans dispose() : leur cycle de vie est ainsi lié
// exactement à celui des Elements, sans risque de "used after being
// disposed" pendant l'animation de fermeture du dialogue.
class _BulkEditDialog extends StatefulWidget {
  final ElevesCubit cubit;
  final String sheetId;
  final String classe;
  final List<AttendanceEleve> eleves;

  const _BulkEditDialog({
    required this.cubit,
    required this.sheetId,
    required this.classe,
    required this.eleves,
  });

  @override
  State<_BulkEditDialog> createState() => _BulkEditDialogState();
}

class _BulkEditDialogState extends State<_BulkEditDialog> {
  late final Map<String, TextEditingController> controllers = {
    for (final e in widget.eleves) e.id: TextEditingController(text: e.numero),
  };
  String? erreur;
  bool saving = false;

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
      erreur = null;
    });
    final res = await widget.cubit.updateNumerosEnMasse(
      widget.sheetId,
      widget.classe,
      widget.eleves,
      {for (final e in widget.eleves) e.id: controllers[e.id]!.text},
    );
    if (!mounted) return;
    if (res == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        saving = false;
        erreur = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Modification multi-élèves (N°)',
        style: TextStyle(
          color: Color(0xFF1E3A8A),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Modifiez librement les N° : l\'unicité est vérifiée uniquement '
              'à l\'enregistrement.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            if (erreur != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    erreur!,
                    style: const TextStyle(
                      color: Color(0xFFB91C1C),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.eleves.length,
                itemBuilder: (_, i) {
                  final e = widget.eleves[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          child: TextField(
                            controller: controllers[e.id],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e.nom, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Fermer sans enregistrer'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
          ),
          onPressed: saving ? null : _save,
          child: Text(saving ? 'Enregistrement...' : 'Enregistrer tout'),
        ),
      ],
    );
  }
}
