import 'package:flutter/material.dart';

/// A bright, playful palette that keeps the app feeling kid-friendly.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C4EF5); // playful violet
  static const Color primaryDark = Color(0xFF4E32C9);
  static const Color secondary = Color(0xFFFF8A3D); // warm orange
  static const Color accentPink = Color(0xFFFF5C8A);
  static const Color accentTeal = Color(0xFF2FD9C4);
  static const Color accentYellow = Color(0xFFFFC94D);
  static const Color accentGreen = Color(0xFF4CD97B);

  static const Color background = Color(0xFFFFF9EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF3A2E5C);
  static const Color textMuted = Color(0xFF8A80A8);

  static const List<Color> funGradient = [primary, accentPink];
  static const List<Color> sunGradient = [secondary, accentYellow];
  static const List<Color> oceanGradient = [accentTeal, primary];
  static const List<Color> leafGradient = [accentGreen, accentTeal];
  static const List<Color> berryGradient = [accentPink, primaryDark];

  static const List<Color> cardPalette = [
    primary,
    secondary,
    accentPink,
    accentTeal,
    accentGreen,
  ];
}
