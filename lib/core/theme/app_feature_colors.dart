import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppFeatureColors {
  static AppPalette _palette = AppPalette.midnight;

  static void bindPalette(AppPalette palette) {
    _palette = palette;
  }

  static Color get gameBg => _palette.primary;
  static Color get gameCard =>
      Color.lerp(_palette.primary, _palette.secondary, 0.45)!;
  static Color get gameBorder => Color.lerp(
    _palette.secondary,
    _palette.accent,
    0.2,
  )!.withValues(alpha: 0.85);

  static Color get sheetBg =>
      Color.lerp(_palette.primary, _palette.secondary, 0.2)!;
  static Color get sheetCard =>
      Color.lerp(_palette.primary, _palette.secondary, 0.62)!;
  static Color get sheetBorder => Color.lerp(
    _palette.secondary,
    _palette.accent,
    0.32,
  )!.withValues(alpha: 0.9);

  static Color get blue =>
      Color.lerp(_palette.secondary, _palette.accent, 0.55)!;
  static Color get green =>
      Color.lerp(_palette.accent, _palette.surface, 0.45)!;
  static Color get amber =>
      Color.lerp(_palette.secondary, _palette.surface, 0.55)!;
  static Color get red => _palette.error;
  static Color get purple =>
      Color.lerp(_palette.secondary, _palette.accent, 0.28)!;
  static Color get cyan => _palette.accent;
  static Color get slate => _palette.surface.withValues(alpha: 0.45);
  static Color get orange => Color.lerp(amber, red, 0.35)!;

  static Color get textMain => _palette.surface;
  static Color get textSub => _palette.surface.withValues(alpha: 0.65);

  static Color get reviewHeat0 => sheetCard;
  static Color get reviewHeat1 => Color.lerp(green, gameBg, 0.55)!;
  static Color get reviewHeat2 => Color.lerp(green, cyan, 0.3)!;
  static Color get reviewHeat3 => Color.lerp(green, textMain, 0.12)!;
  static Color get reviewHeat4 => Color.lerp(green, textMain, 0.24)!;
  static Color get reviewHeat5 => Color.lerp(green, textMain, 0.34)!;

  static List<Color> get srsLevelColors => [
    slate,
    red,
    orange,
    amber,
    blue,
    green,
  ];

  static Color reviewHeatColor(int value) {
    if (value == 0) return reviewHeat0;
    if (value < 5) return reviewHeat1;
    if (value < 10) return reviewHeat2;
    if (value < 15) return reviewHeat3;
    if (value < 20) return reviewHeat4;
    return reviewHeat5;
  }
}
