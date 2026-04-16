import 'package:flutter/material.dart';

class AppPalette {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color error;

  const AppPalette({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.error,
  });

  static const midnight = AppPalette(
    name: 'Midnight',
    primary: Color(0xFF222831),
    secondary: Color(0xFF393E46),
    accent: Color(0xFF00ADB5),
    surface: Color(0xFFEEEEEE),
    error: Color(0xFFE53935),
  );

  static const sky = AppPalette(
    name: 'Sky',
    primary: Color(0xFF112D4E),
    secondary: Color(0xFF3F72AF),
    accent: Color(0xFFDBE2EF),
    surface: Color(0xFFF9F7F7),
    error: Color(0xFFD32F2F),
  );

  static const List<AppPalette> all = [midnight, sky];
}
