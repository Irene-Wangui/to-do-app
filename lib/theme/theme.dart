import 'package:flutter/material.dart';
import 'styles.dart'; // Import styles (which exports colors)

// --- Light Theme ---
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  // Use ColorScheme.fromSeed to automatically generate Material 3 color scheme
  colorScheme: ColorScheme.fromSeed(
    seedColor: $styles.colors.primary, // Use primary blue as seed
    brightness: Brightness.light,
    // You can override specific generated colors if needed:
    // secondary: $styles.colors.accent, // Example: Force accent color
    // surface: $styles.colors.surface, // Example: Force specific surface
  ),
  // Define TextTheme directly using styles
  textTheme: TextTheme(
    displayLarge: $styles.text.displayLarge,
    displayMedium: $styles.text.displayMedium,
    displaySmall: $styles.text.displaySmall,
    headlineLarge: $styles.text.headlineLarge,
    headlineMedium: $styles.text.headlineMedium,
    headlineSmall: $styles.text.headlineSmall,
    titleLarge: $styles.text.titleLarge,
    titleMedium: $styles.text.titleMedium,
    titleSmall: $styles.text.titleSmall,
    bodyLarge: $styles.text.bodyLarge,
    bodyMedium: $styles.text.bodyMedium,
    bodySmall: $styles.text.bodySmall,
    labelLarge: $styles.text.labelLarge,
    labelMedium: $styles.text.labelMedium,
    labelSmall: $styles.text.labelSmall,
  ).apply(
    // Apply default text color for the theme
    bodyColor: $styles.colors.black, // Or ColorScheme.onBackground
    displayColor: $styles.colors.black,
  ),
  scaffoldBackgroundColor: $styles.colors.greyLight, // Basic light background
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.yellow, // Or $styles.colors.white
    foregroundColor: $styles.colors.black, // Icons/text on appbar
    elevation: 0,
    scrolledUnderElevation: 0.5,
    surfaceTintColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: $styles.colors.primary, // Button background
      foregroundColor: $styles.colors.white, // Button text/icon
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0), // Keep your radius
      ),
      textStyle: $styles.text.labelLarge, // Use label style
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: $styles.colors.primary, // Text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
      ),
      textStyle: $styles.text.labelLarge.copyWith(fontWeight: FontWeight.bold),
    ),
  ),
  // Add other simple widget themes here ONLY if needed
  // cardTheme: CardTheme(...)
  // inputDecorationTheme: InputDecorationTheme(...)
);

// --- Dark Theme ---
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  // Use ColorScheme.fromSeed for dark mode too
  colorScheme: ColorScheme.fromSeed(
    seedColor: $styles.colors.primary, // Use same seed color
    brightness: Brightness.dark, // IMPORTANT: Set brightness to dark
    // Override specific dark colors if seed generation isn't perfect:
    // secondary: $styles.colors.accent, // Keep accent maybe?
    // background: $styles.colors.black, // Force specific background
  ),
  // Define TextTheme directly using styles (styles themselves don't change)
  textTheme: TextTheme(
    displayLarge: $styles.text.displayLarge,
    displayMedium: $styles.text.displayMedium,
    displaySmall: $styles.text.displaySmall,
    headlineLarge: $styles.text.headlineLarge,
    headlineMedium: $styles.text.headlineMedium,
    headlineSmall: $styles.text.headlineSmall,
    titleLarge: $styles.text.titleLarge,
    titleMedium: $styles.text.titleMedium,
    titleSmall: $styles.text.titleSmall,
    bodyLarge: $styles.text.bodyLarge,
    bodyMedium: $styles.text.bodyMedium,
    bodySmall: $styles.text.bodySmall,
    labelLarge: $styles.text.labelLarge,
    labelMedium: $styles.text.labelMedium,
    labelSmall: $styles.text.labelSmall,
  ).apply(
    // Apply default text color for dark theme
    bodyColor: $styles.colors.white, // Or ColorScheme.onBackground
    displayColor: $styles.colors.white,
  ),
  scaffoldBackgroundColor: $styles.colors.black, // Basic dark background
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent, // Or $styles.colors.black
    foregroundColor: $styles.colors.white, // Icons/text on appbar
    elevation: 0,
    scrolledUnderElevation: 0.5,
    surfaceTintColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: $styles.colors.accent, // Keep button background
      foregroundColor: $styles.colors.white, // Keep button text/icon
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
      ),
      textStyle: $styles.text.labelLarge,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: $styles.colors.primary, // Keep primary text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
      ),
      textStyle: $styles.text.labelLarge.copyWith(fontWeight: FontWeight.bold),
    ),
  ),
  // Only add overrides if ColorScheme.fromSeed isn't sufficient
);
