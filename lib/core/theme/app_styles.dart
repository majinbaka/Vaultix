import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
}

class AppTextStyles {
  static TextStyle ui({
    Color? color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 0,
    FontStyle fontStyle = FontStyle.normal,
    double? height,
    TextDecoration? decoration,
    String? fontFamily,
  }) {
    final base = GoogleFonts.inter(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
    final merged = base.copyWith(height: height, decoration: decoration);
    if (fontFamily == null) {
      return merged;
    }
    return merged.copyWith(fontFamily: fontFamily);
  }

  static TextStyle inter({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    double? height,
    TextDecoration? decoration,
  }) {
    return ui(
      color: color,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 0,
      fontStyle: fontStyle ?? FontStyle.normal,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle brand(
    AppPalette palette, {
    double fontSize = 32,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 1,
    FontStyle fontStyle = FontStyle.normal,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      color: color ?? palette.surface,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      shadows: shadows,
    );
  }

  static TextStyle bodyPrimary(
    AppPalette palette, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double opacity = 1,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: palette.primary.withValues(alpha: opacity),
    );
  }

  static TextStyle bodySurface(
    AppPalette palette, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double opacity = 1,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: palette.surface.withValues(alpha: opacity),
    );
  }

  static TextStyle bodyAccent(
    AppPalette palette, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double opacity = 1,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: palette.accent.withValues(alpha: opacity),
    );
  }

  static TextStyle navLabel(Color color, {required bool selected}) {
    return TextStyle(
      fontSize: 11,
      color: color,
      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
    );
  }
}

class AppDecorations {
  static BoxDecoration elevatedCard(AppPalette palette) {
    return BoxDecoration(
      color: palette.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      boxShadow: [
        BoxShadow(
          color: palette.primary.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration navBar(AppPalette palette) {
    return BoxDecoration(
      color: palette.primary,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadii.xl),
        topRight: Radius.circular(AppRadii.xl),
      ),
    );
  }

  static BoxDecoration centerAction(AppPalette palette) {
    return BoxDecoration(
      color: palette.secondary,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: palette.primary.withValues(alpha: 0.5),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class AppButtonStyles {
  static ButtonStyle primary(AppPalette palette) {
    return ElevatedButton.styleFrom(
      backgroundColor: palette.primary,
      disabledBackgroundColor: palette.secondary.withValues(alpha: 0.5),
      foregroundColor: palette.accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      elevation: 2,
    );
  }
}

class AppFieldStyles {
  static OutlineInputBorder border({required Color color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
