import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultix/core/theme/app_colors.dart';
import 'package:vaultix/core/theme/app_feature_colors.dart';

void main() {
  group('AppFeatureColors', () {
    setUp(() {
      AppFeatureColors.bindPalette(AppPalette.midnight);
    });

    test('bindPalette does not throw', () {
      expect(() => AppFeatureColors.bindPalette(AppPalette.midnight), returnsNormally);
      expect(() => AppFeatureColors.bindPalette(AppPalette.sky), returnsNormally);
    });

    test('gameBg returns a Color', () {
      expect(AppFeatureColors.gameBg, isA<Color>());
    });

    test('gameCard returns a Color', () {
      expect(AppFeatureColors.gameCard, isA<Color>());
    });

    test('gameBorder returns a Color', () {
      expect(AppFeatureColors.gameBorder, isA<Color>());
    });

    test('sheetBg returns a Color', () {
      expect(AppFeatureColors.sheetBg, isA<Color>());
    });

    test('sheetCard returns a Color', () {
      expect(AppFeatureColors.sheetCard, isA<Color>());
    });

    test('sheetBorder returns a Color', () {
      expect(AppFeatureColors.sheetBorder, isA<Color>());
    });

    test('blue returns a Color', () {
      expect(AppFeatureColors.blue, isA<Color>());
    });

    test('green returns a Color', () {
      expect(AppFeatureColors.green, isA<Color>());
    });

    test('amber returns a Color', () {
      expect(AppFeatureColors.amber, isA<Color>());
    });

    test('red equals palette error color', () {
      expect(AppFeatureColors.red, AppPalette.midnight.error);
    });

    test('purple returns a Color', () {
      expect(AppFeatureColors.purple, isA<Color>());
    });

    test('cyan equals palette accent color', () {
      expect(AppFeatureColors.cyan, AppPalette.midnight.accent);
    });

    test('slate returns a Color', () {
      expect(AppFeatureColors.slate, isA<Color>());
    });

    test('orange returns a Color', () {
      expect(AppFeatureColors.orange, isA<Color>());
    });

    test('textMain equals palette surface color', () {
      expect(AppFeatureColors.textMain, AppPalette.midnight.surface);
    });

    test('textSub returns a Color', () {
      expect(AppFeatureColors.textSub, isA<Color>());
    });

    test('reviewHeat0 returns a Color', () {
      expect(AppFeatureColors.reviewHeat0, isA<Color>());
    });

    test('reviewHeat1 returns a Color', () {
      expect(AppFeatureColors.reviewHeat1, isA<Color>());
    });

    test('reviewHeat2 returns a Color', () {
      expect(AppFeatureColors.reviewHeat2, isA<Color>());
    });

    test('reviewHeat3 returns a Color', () {
      expect(AppFeatureColors.reviewHeat3, isA<Color>());
    });

    test('reviewHeat4 returns a Color', () {
      expect(AppFeatureColors.reviewHeat4, isA<Color>());
    });

    test('reviewHeat5 returns a Color', () {
      expect(AppFeatureColors.reviewHeat5, isA<Color>());
    });

    test('srsLevelColors has 6 entries', () {
      expect(AppFeatureColors.srsLevelColors.length, 6);
    });

    group('reviewHeatColor', () {
      test('returns reviewHeat0 for value 0', () {
        expect(AppFeatureColors.reviewHeatColor(0), AppFeatureColors.reviewHeat0);
      });

      test('returns reviewHeat1 for value 1 (< 5)', () {
        expect(AppFeatureColors.reviewHeatColor(1), AppFeatureColors.reviewHeat1);
      });

      test('returns reviewHeat1 for value 4 (< 5)', () {
        expect(AppFeatureColors.reviewHeatColor(4), AppFeatureColors.reviewHeat1);
      });

      test('returns reviewHeat2 for value 5 (< 10)', () {
        expect(AppFeatureColors.reviewHeatColor(5), AppFeatureColors.reviewHeat2);
      });

      test('returns reviewHeat2 for value 9 (< 10)', () {
        expect(AppFeatureColors.reviewHeatColor(9), AppFeatureColors.reviewHeat2);
      });

      test('returns reviewHeat3 for value 10 (< 15)', () {
        expect(AppFeatureColors.reviewHeatColor(10), AppFeatureColors.reviewHeat3);
      });

      test('returns reviewHeat3 for value 14 (< 15)', () {
        expect(AppFeatureColors.reviewHeatColor(14), AppFeatureColors.reviewHeat3);
      });

      test('returns reviewHeat4 for value 15 (< 20)', () {
        expect(AppFeatureColors.reviewHeatColor(15), AppFeatureColors.reviewHeat4);
      });

      test('returns reviewHeat4 for value 19 (< 20)', () {
        expect(AppFeatureColors.reviewHeatColor(19), AppFeatureColors.reviewHeat4);
      });

      test('returns reviewHeat5 for value 20', () {
        expect(AppFeatureColors.reviewHeatColor(20), AppFeatureColors.reviewHeat5);
      });

      test('returns reviewHeat5 for large value', () {
        expect(AppFeatureColors.reviewHeatColor(100), AppFeatureColors.reviewHeat5);
      });
    });

    group('with sky palette', () {
      setUp(() {
        AppFeatureColors.bindPalette(AppPalette.sky);
      });

      test('red equals sky error color', () {
        expect(AppFeatureColors.red, AppPalette.sky.error);
      });

      test('cyan equals sky accent color', () {
        expect(AppFeatureColors.cyan, AppPalette.sky.accent);
      });

      test('textMain equals sky surface color', () {
        expect(AppFeatureColors.textMain, AppPalette.sky.surface);
      });

      test('gameBg equals sky primary color', () {
        expect(AppFeatureColors.gameBg, AppPalette.sky.primary);
      });
    });
  });
}
