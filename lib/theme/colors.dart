import 'package:flutter/material.dart';

@immutable
class AppColors {
  // --- Brand ---
  final Color primary = const Color(0xFF5669FF); // Your Blue
  final Color accent = const Color(0xFFFF9100); // Vibrant Orange Accent

  // --- Neutrals/UI ---
  final Color textBody = const Color(0xFF514F4D); // For specific overrides if needed
  final Color textCaption = const Color(0xFF7D7873); // For specific overrides if needed
  final Color surface = const Color(0xFFF8ECE5); // Your Off-white, maybe for light cards
  final Color white = Colors.white;
  final Color black = const Color(0xFF1E1B18);
  final Color greyLight = Colors.grey.shade300; // Keep for borders etc.
  final Color greyMedium = const Color(0xFF9D9995);

  // Feedback
  final Color error = Colors.red;
  final Color success = Colors.green;
} 
