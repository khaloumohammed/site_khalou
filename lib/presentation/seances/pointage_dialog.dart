// lib/presentation/dialogs/pointage_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialogue d'affichage des pointages du jour
class PointageDialog extends StatelessWidget {
  final List<Map<String, dynamic>> pointages;
  final String classe;
  final String date;
  final String jourHoraire;

  const PointageDialog({
    super.key,
    required this.pointages,
    required this.classe,
    required this.date,
    required this.jourHoraire,
  });

  // Constantes de couleurs par statut
  static const Map<String, Color> _statusColors = {
    'présent': Color(0xFF10B981), // Vert
    'absent': Color(0xFFEF4444), // Rouge
    'retard': Color(0xFFF59E0B), // Orange
    'excusé': Color(0xFF6366F1), // Violet
    'excusée': Color(0xFF6366F1), // Violet
  };

  static const _defaultStatusColor = Color(0xFF64748B); // Gris

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildPointagesList()),
            const SizedBox(height: 16),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  /// Construit l'en-tête du dialogue
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Pointage du jour',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          classe.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          jourHoraire,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Construit la liste des pointages
  Widget _buildPointagesList() {
    if (pointages.isEmpty) {
      return const Center(
        child: Text('Aucun pointage enregistré pour aujourd\'hui'),
      );
    }

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 16,
        columns: const [
          DataColumn(
            label: Center(
              child: Text('N°', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Center(
              child: Text('NOM', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          DataColumn(
            label: Center(
              child: Text(
                'STATUT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        rows: pointages.map((pointage) {
          final numero = _getStringValue(pointage['N°']);
          final nom = _getStringValue(pointage['Nom']).toUpperCase();
          final statut = _getStringValue(pointage['Statut']).toUpperCase();
          final statusColor = _getStatusColor(statut);

          return DataRow(
            cells: [
              DataCell(
                Center(
                  child: Text(
                    numero,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    nom,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Center(child: _buildStatusBadge(statut, statusColor))),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Construit un badge de statut
  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Construit le bouton de fermeture
  Widget _buildCloseButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pop(),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text('FERMER', style: TextStyle(letterSpacing: 1)),
    );
  }

  /// Récupère une valeur de chaîne sûre
  String _getStringValue(dynamic value) {
    return (value ?? '').toString().trim();
  }

  /// Obtient la couleur du statut
  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();

    // Recherche directe dans la map
    for (final entry in _statusColors.entries) {
      if (statusLower.contains(entry.key)) {
        return entry.value;
      }
    }

    return _defaultStatusColor;
  }
}
