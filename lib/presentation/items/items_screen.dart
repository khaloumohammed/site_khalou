import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../home/google_sheet_cubit.dart';
import '../home/google_sheet_state.dart';
import 'item_cubit.dart';
import 'item_state.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _loadItemsIfConnected();
  }

  void _loadItemsIfConnected() {
    final sheetCubit = context.read<GoogleSheetCubit>();
    final sheetState = sheetCubit.state;

    if (sheetState is SheetConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _loadItemsFromSheet(sheetState.sheetId);
      });
    }
  }

  Future<void> _loadItemsFromSheet(String sheetId) async {
    final itemCubit = context.read<ItemCubit>();
    try {
      await itemCubit.fetchItems(sheetId);
    } catch (_) {
      return;
    }
  }

  Future<void> _refresh() async {
    final sheetCubit = context.read<GoogleSheetCubit>();
    final sheetState = sheetCubit.state;

    if (sheetState is SheetConnected) {
      await _loadItemsFromSheet(sheetState.sheetId);
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2 * 255),
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
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2 * 255),
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        title: Container(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          child: const Text(
            'Critères de Pointage',
            style: TextStyle(
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
              onPressed: _refresh,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ItemCubit, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is ItemLoading) {
            return _buildLoadingState();
          } else if (state is ItemLoaded) {
            return _buildLoadedState(context, state);
          } else if (state is ItemError) {
            return _buildErrorState(state);
          } else {
            return _buildEmptyState();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Ajouter',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
    );
  }

  Widget _buildLoadedState(BuildContext context, ItemLoaded state) {
    if (state.items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF1E3A8A),
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          final colorPalette = [
            const Color(0xFF10B981),
            const Color(0xFF3B82F6),
            const Color(0xFF8B5CF6),
            const Color(0xFFEF4444),
            const Color(0xFFF59E0B),
            const Color(0xFF06B6D4),
            const Color(0xFF84CC16),
          ];
          final itemColor = colorPalette[index % colorPalette.length];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: itemColor.withValues(alpha: 0.4 * 255),
                    width: 1.2,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                  ),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
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
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            itemColor.withValues(alpha: 0.8 * 255),
                            itemColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: itemColor.withValues(alpha: 0.08 * 255),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      item.critere,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: itemColor.withValues(alpha: 0.9 * 255),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "ID: ${item.id}",
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
                        color: itemColor.withValues(alpha: 0.15 * 255),
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
                              onTap: () => _showEditDialog(context, item),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildCRUDActionButton(
                              icon: Icons.delete_rounded,
                              label: 'Supprimer',
                              color: const Color(0xFFEF4444),
                              onTap: () => _showDeleteDialog(context, item),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ItemError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.checklist_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Aucun critère trouvé",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Ajoutez un critère pour commencer"),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("Ajouter un critère"),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Nouveau critère",
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Nom du critère",
              hintText: "Ex: Présence, Ponctualité...",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Veuillez entrer un critère";
              }
              return null;
            },
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF8FAFC),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final sheetCubit = context.read<GoogleSheetCubit>();
              final sheetState = sheetCubit.state;

              if (sheetState is SheetConnected) {
                await context.read<ItemCubit>().addItem(
                  sheetState.sheetId,
                  controller.text.trim(),
                );

                setState(() {
                  expandedIndex = -1;
                });
                await _refresh();
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSuccessSnackBar("Critère ajouté avec succès");
              } else {
                _showErrorSnackBar("Aucune feuille Google Sheets connectée");
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic item) {
    final controller = TextEditingController(text: item.critere);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Modifier le critère",
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Nouveau nom",
              hintText: "Ex: Assiduité",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Veuillez entrer un critère";
              }
              return null;
            },
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF8FAFC),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final sheetCubit = context.read<GoogleSheetCubit>();
              final sheetState = sheetCubit.state;

              if (sheetState is SheetConnected) {
                final oldCritere = item.critere;
                final newCritere = controller.text.trim();

                await context.read<ItemCubit>().updateItemMethod(
                  sheetState.sheetId,
                  oldCritere,
                  newCritere,
                );

                setState(() {
                  expandedIndex = -1;
                });
                await _refresh();
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSuccessSnackBar("Critère modifié avec succès");
              } else {
                _showErrorSnackBar("Aucune feuille Google Sheets connectée");
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Supprimer le critère",
          style: TextStyle(
            color: Color(0xFFEF4444),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: Text(
          "Voulez-vous vraiment supprimer le critère '${item.critere}' ?",
          style: const TextStyle(fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF8FAFC),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final sheetCubit = context.read<GoogleSheetCubit>();
              final sheetState = sheetCubit.state;

              if (sheetState is SheetConnected) {
                await context.read<ItemCubit>().deleteItemMethod(
                  sheetState.sheetId,
                  item.critere,
                );

                setState(() {
                  expandedIndex = -1;
                });
                await _refresh();
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSuccessSnackBar("Critère supprimé avec succès");
              } else {
                _showErrorSnackBar("Aucune feuille Google Sheets connectée");
              }
            },
            child: const Text("Supprimer"),
          ),
        ],
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15 * 255),
                color.withValues(alpha: 0.08 * 255),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3 * 255),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05 * 255),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
