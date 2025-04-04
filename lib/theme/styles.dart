import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart'; // Import colors

// Export colors for convenience
export 'colors.dart';

// --- Global Style Accessor ---
// Simple way to access colors and text styles
final $styles = AppStyle();

@immutable
class AppStyle {
  // Provides access to colors and text styles
  final AppColors colors = AppColors();
  final AppTextStyles text = AppTextStyles();
}

// --- Text Styles ---
@immutable
class AppTextStyles {
  // No default colors assigned here; they come from ThemeData

  // Base Fonts
  TextStyle get _headlineFont => GoogleFonts.lato();
  TextStyle get _titleFont => GoogleFonts.lato();
  TextStyle get _contentFont => GoogleFonts.lato();
  TextStyle get _labelFont => GoogleFonts.lato(fontWeight: FontWeight.bold);

  // Specific Text Styles (Material 3 mapping in comments)
  // Keep names aligned with ThemeData.textTheme for clarity
  late final TextStyle displayLarge =
      _headlineFont.copyWith(fontSize: 32, fontWeight: FontWeight.w600); // M3 DisplayLarge (H1)
  late final TextStyle displayMedium =
      _headlineFont.copyWith(fontSize: 28, fontWeight: FontWeight.w600); // M3 DisplayMedium (H2)
  late final TextStyle displaySmall =
      _headlineFont.copyWith(fontSize: 24, fontWeight: FontWeight.w500); // M3 DisplaySmall (H3)

  late final TextStyle headlineLarge =
      _titleFont.copyWith(fontSize: 22, fontWeight: FontWeight.w700); // M3 HeadlineLarge (H4)
  late final TextStyle headlineMedium =
      _titleFont.copyWith(fontSize: 18, fontWeight: FontWeight.w600); // M3 HeadlineMedium (H5)
  late final TextStyle headlineSmall =
      _titleFont.copyWith(fontSize: 16, fontWeight: FontWeight.w600); // M3 HeadlineSmall (H6)

  late final TextStyle titleLarge = headlineLarge; // Reuse headline styles for title
  late final TextStyle titleMedium = headlineMedium;
  late final TextStyle titleSmall = headlineSmall;

  late final TextStyle bodyLarge = _contentFont.copyWith(fontSize: 16); // M3 BodyLarge
  late final TextStyle bodyMedium = _contentFont.copyWith(fontSize: 14); // M3 BodyMedium
  late final TextStyle bodySmall = _contentFont.copyWith(fontSize: 12); // M3 BodySmall

  late final TextStyle labelLarge = _labelFont.copyWith(fontSize: 14); // M3 LabelLarge
  late final TextStyle labelMedium = _labelFont.copyWith(fontSize: 12); // M3 LabelMedium
  late final TextStyle labelSmall = _labelFont.copyWith(fontSize: 11); // M3 LabelSmall
}
