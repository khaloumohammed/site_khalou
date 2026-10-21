// lib/presentation/screens/statistiques_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/home/google_sheet_state.dart';

/// Écran de statistiques
class StatistiquesScreen extends StatelessWidget {
  const StatistiquesScreen({super.key});

  static const _primaryColor = Color(0xFF1E3A8A);
  static const _statCards = [
    ('Classes', Icons.class_rounded, 0xFFF59E0B, 'classCount'),
    ('Séances', Icons.schedule_rounded, 0xFF3B82F6, 'seancesCount'),
    ('Critères', Icons.people_alt_rounded, 0xFF10B981, 'criteresCount'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(context),
      body: BlocBuilder<GoogleSheetCubit, SheetState>(
        builder: (context, state) {
          if (state is SheetConnected) {
            return _buildStatsContent(context);
          }
          return _buildDisconnectedView();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: _primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.go('/menuprincipal'),
      ),
      title: const Text(
        'Statistiques',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildStatsContent(BuildContext context) {
    final cubit = context.read<GoogleSheetCubit>();
    final stats = [cubit.classCount, cubit.seancesCount, cubit.criteresCount];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        ..._buildStatCards(stats),
        const SizedBox(height: 32),
        _buildDiagnosticCard(context),
      ],
    );
  }

  List<Widget> _buildStatCards(List<int> values) {
    return _statCards.asMap().entries.expand<Widget>((entry) {
      final idx = entry.key;
      final (title, icon, colorValue, _) = entry.value;
      final color = Color(colorValue);
      final value = values[idx].toString();

      return [
        _buildStatCard(icon: icon, title: title, value: value, color: color),
        if (idx < _statCards.length - 1) const SizedBox(height: 16),
      ];
    }).toList();
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final sheetState = context.read<GoogleSheetCubit>().state;
        if (sheetState is SheetConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Diagnostic exécuté'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Lancer un diagnostic rapide',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnectedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucune feuille connectée',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Connectez-vous à une feuille Google Sheets pour afficher les statistiques',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
