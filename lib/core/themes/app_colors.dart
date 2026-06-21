import 'package:flutter/material.dart';

/// NutriSalud 2.0 brand palette.
///
/// Brand attributes: modern, trustworthy, medical, healthy, friendly.
/// The greens are kept from the original identity but recalibrated for
/// WCAG AA contrast on both light and dark surfaces.
abstract final class AppColors {
  // Brand
  static const Color brandGreen = Color(0xFF3E7C3A); // primary seed
  static const Color brandGreenDark = Color(0xFF2C5E2E);
  static const Color leaf = Color(0xFF6BA368); // legacy light green
  static const Color lime = Color(0xFFA3C9A0);

  // Accent (warm, food-friendly)
  static const Color apricot = Color(0xFFE8A04C);
  static const Color berry = Color(0xFFB6465F);

  // Neutrals
  static const Color offWhite = Color(0xFFFAFAF7);
  static const Color charcoal = Color(0xFF1C1F1C);

  // Semantic
  static const Color success = Color(0xFF3E7C3A);
  static const Color warning = Color(0xFFE8A04C);
  static const Color danger = Color(0xFFC94F4F);
}
