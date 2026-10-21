import 'package:flutter/material.dart';

/// Palette de couleurs moderne et cohérente pour l'application
class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF4F46E5); // Indigo moderne
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  static const Color secondary = Color(0xFF10B981); // Vert émeraude
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  static const Color accent = Color(0xFF8B5CF6); // Violet
  static const Color accentLight = Color(0xFFA78BFA);

  // Couleurs de statut
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);

  // Texte
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // Bordures
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Palette pour les cartes d'élèves (couleurs vives et modernes)
  static const List<Color> cardPalette = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF10B981), // Vert
    Color(0xFF8B5CF6), // Violet
    Color(0xFFF59E0B), // Ambre
    Color(0xFFEF4444), // Rouge
    Color(0xFF3B82F6), // Bleu
    Color(0xFFEC4899), // Rose
    Color(0xFF06B6D4), // Cyan
  ];

  // Backgrounds pour les cartes (versions très claires)
  static const List<Color> cardBackgrounds = [
    Color(0xFFEEF2FF), // Indigo clair
    Color(0xFFD1FAE5), // Vert clair
    Color(0xFFF5F3FF), // Violet clair
    Color(0xFFFEF3C7), // Ambre clair
    Color(0xFFFEE2E2), // Rouge clair
    Color(0xFFDCEEFE), // Bleu clair
    Color(0xFFFCE7F3), // Rose clair
    Color(0xFFCFFAFE), // Cyan clair
  ];

  // Gradients modernes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  );

  // Ombres
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
