import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:attendance_app/config/app_router.dart';
import 'package:attendance_app/presentation/classes/class_cubit.dart';
import 'package:attendance_app/presentation/classes/class_state.dart';
import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/classes/class_model.dart';

import '../home/google_sheet_state.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    _loadClassesIfConnected();
  }

  void _loadClassesIfConnected() {
    final sheetCubit = context.read<GoogleSheetCubit>();
    final sheetState = sheetCubit.state;

    if (sheetState is SheetConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadClassesFromSheet(sheetState.sheetId);
      });
    }
  }

  Future<void> _loadClassesFromSheet(String sheetId) async {
    final classCubit = context.read<ClassCubit>();
    try {
      await classCubit.loadClasses(sheetId);
    } catch (_) {
      return;
    }
  }

  Future<void> _refresh() async {
    final sheetState = context.read<GoogleSheetCubit>().state;
    if (sheetState is SheetConnected) {
      await _loadClassesFromSheet(sheetState.sheetId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSearchMode
              ? Container(
                  height: 45,
                  margin: const EdgeInsets.only(right: 16),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    key: const ValueKey('search_field'),
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher une classe...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      suffixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    onChanged: (query) {
                      context.read<ClassCubit>().searchClasses(query);
                    },
                  ),
                )
              : Container(
                  key: const ValueKey('title'),
                  padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                  child: const Text(
                    'Gestion des Classes',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSearchMode
                ? Container(
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
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
                        Icons.close_rounded,
                        color: Color(0xFFEF4444),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isSearchMode = !_isSearchMode;
                          if (!_isSearchMode) {
                            _searchController.clear();
                            context.read<ClassCubit>().resetSearch();
                          }
                        });
                        // Ajout d'une animation de transition
                        if (_isSearchMode) {
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                          _searchController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _searchController.text.length),
                          );
                        }
                      },
                    ),
                  )
                : Container(
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
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearchMode = true;
                        });
                      },
                    ),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refresh,
          ),
        ],
      ),
      body: BlocConsumer<ClassCubit, ClassState>(
        listener: (context, state) {
          if (state is ClassError) {
            _showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ClassLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClassLoaded) {
            return _buildClassList(state.classes);
          } else if (state is ClassError) {
            return _buildErrorView(state.message);
          } else {
            return _buildEmptyView();
          }
        },
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildClassList(List<ClassModel> classes) {
    if (classes.isEmpty) {
      return _buildEmptyView();
    }

    final colorPalette = [
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
    ];

    return RefreshIndicator(
      color: const Color(0xFF1E3A8A),
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final classModel = classes[index];
          final classColor = colorPalette[index % colorPalette.length];

          return GestureDetector(
            onTap: () {
              final sheetState = context.read<GoogleSheetCubit>().state;
              if (sheetState is SheetConnected) {
                context.push(
                  AppRoutes.eleves,
                  extra: {
                    'className': classModel.name,
                    'sheetId': sheetState.sheetId,
                  },
                );
              }
            },
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: classColor.withValues(alpha: 0.4 * 255),
                    width: 1.2,
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          classColor.withValues(alpha: 0.8 * 255),
                          classColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: classColor.withValues(alpha: 0.25 * 255),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.class_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    classModel.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: classColor.withValues(alpha: 0.9 * 255),
                    ),
                  ),
                  subtitle: Text(
                    '${classModel.studentCount} élève${classModel.studentCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.class_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucune classe disponible',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Ajoutez une classe pour commencer',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
