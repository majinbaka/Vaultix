import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultix/core/theme/app_colors.dart';
import 'package:vaultix/core/theme/app_styles.dart';

void main() {
  const palette = AppPalette.midnight;

  group('AppRadii', () {
    test('sm is 12', () => expect(AppRadii.sm, 12));
    test('md is 16', () => expect(AppRadii.md, 16));
    test('lg is 20', () => expect(AppRadii.lg, 20));
    test('xl is 24', () => expect(AppRadii.xl, 24));
  });

  group('AppTextStyles', () {
    // AppTextStyles.ui/inter/brand use GoogleFonts.inter which requires bundled
    // font assets or a live network. Those are tested as part of widget tests.
    // Here we test the pure-Dart style helpers.

    group('bodyPrimary()', () {
      test('returns a TextStyle', () {
        expect(AppTextStyles.bodyPrimary(palette), isA<TextStyle>());
      });

      test('color is palette primary', () {
        final style = AppTextStyles.bodyPrimary(palette);
        expect(style.color?.toARGB32(), palette.primary.withValues(alpha: 1).toARGB32());
      });

      test('default fontSize is 14', () {
        expect(AppTextStyles.bodyPrimary(palette).fontSize, 14);
      });

      test('applies custom fontSize', () {
        expect(AppTextStyles.bodyPrimary(palette, fontSize: 18).fontSize, 18);
      });

      test('applies custom fontWeight', () {
        final style = AppTextStyles.bodyPrimary(palette, fontWeight: FontWeight.bold);
        expect(style.fontWeight, FontWeight.bold);
      });

      test('applies letterSpacing', () {
        final style = AppTextStyles.bodyPrimary(palette, letterSpacing: 1.5);
        expect(style.letterSpacing, 1.5);
      });

      test('applies opacity', () {
        final style = AppTextStyles.bodyPrimary(palette, opacity: 0.5);
        expect(style.color?.a, closeTo(palette.primary.withValues(alpha: 0.5).a, 0.01));
      });
    });

    group('bodySurface()', () {
      test('returns a TextStyle', () {
        expect(AppTextStyles.bodySurface(palette), isA<TextStyle>());
      });

      test('color is palette surface', () {
        final style = AppTextStyles.bodySurface(palette);
        expect(style.color?.toARGB32(), palette.surface.withValues(alpha: 1).toARGB32());
      });

      test('default fontSize is 14', () {
        expect(AppTextStyles.bodySurface(palette).fontSize, 14);
      });

      test('applies custom fontWeight', () {
        final style = AppTextStyles.bodySurface(palette, fontWeight: FontWeight.w600);
        expect(style.fontWeight, FontWeight.w600);
      });

      test('applies opacity', () {
        final style = AppTextStyles.bodySurface(palette, opacity: 0.7);
        expect(style.color?.a, closeTo(palette.surface.withValues(alpha: 0.7).a, 0.01));
      });
    });

    group('bodyAccent()', () {
      test('returns a TextStyle', () {
        expect(AppTextStyles.bodyAccent(palette), isA<TextStyle>());
      });

      test('color is palette accent', () {
        final style = AppTextStyles.bodyAccent(palette);
        expect(style.color?.toARGB32(), palette.accent.withValues(alpha: 1).toARGB32());
      });

      test('default fontSize is 14', () {
        expect(AppTextStyles.bodyAccent(palette).fontSize, 14);
      });

      test('applies opacity', () {
        final style = AppTextStyles.bodyAccent(palette, opacity: 0.3);
        expect(style.color?.a, closeTo(palette.accent.withValues(alpha: 0.3).a, 0.01));
      });
    });

    group('navLabel()', () {
      test('returns a TextStyle', () {
        expect(AppTextStyles.navLabel(Colors.white, selected: false), isA<TextStyle>());
      });

      test('fontSize is 11', () {
        final style = AppTextStyles.navLabel(Colors.white, selected: false);
        expect(style.fontSize, 11);
      });

      test('selected uses w600', () {
        final style = AppTextStyles.navLabel(Colors.white, selected: true);
        expect(style.fontWeight, FontWeight.w600);
      });

      test('unselected uses normal weight', () {
        final style = AppTextStyles.navLabel(Colors.white, selected: false);
        expect(style.fontWeight, FontWeight.normal);
      });

      test('applies color', () {
        final style = AppTextStyles.navLabel(Colors.green, selected: false);
        expect(style.color, Colors.green);
      });
    });
  });

  group('AppDecorations', () {
    group('elevatedCard()', () {
      test('returns a BoxDecoration', () {
        expect(AppDecorations.elevatedCard(palette), isA<BoxDecoration>());
      });

      test('color is palette surface', () {
        final decoration = AppDecorations.elevatedCard(palette);
        expect(decoration.color, palette.surface);
      });

      test('has box shadow', () {
        final decoration = AppDecorations.elevatedCard(palette);
        expect(decoration.boxShadow, isNotEmpty);
      });
    });

    group('navBar()', () {
      test('returns a BoxDecoration', () {
        expect(AppDecorations.navBar(palette), isA<BoxDecoration>());
      });

      test('color is palette primary', () {
        final decoration = AppDecorations.navBar(palette);
        expect(decoration.color, palette.primary);
      });
    });

    group('centerAction()', () {
      test('returns a BoxDecoration', () {
        expect(AppDecorations.centerAction(palette), isA<BoxDecoration>());
      });

      test('color is palette secondary', () {
        final decoration = AppDecorations.centerAction(palette);
        expect(decoration.color, palette.secondary);
      });

      test('shape is circle', () {
        final decoration = AppDecorations.centerAction(palette);
        expect(decoration.shape, BoxShape.circle);
      });
    });
  });

  group('AppButtonStyles', () {
    group('primary()', () {
      test('returns a ButtonStyle', () {
        expect(AppButtonStyles.primary(palette), isA<ButtonStyle>());
      });
    });
  });

  group('AppFieldStyles', () {
    group('border()', () {
      test('returns an OutlineInputBorder', () {
        expect(AppFieldStyles.border(color: Colors.blue), isA<OutlineInputBorder>());
      });

      test('applies color', () {
        final border = AppFieldStyles.border(color: Colors.red);
        expect(border.borderSide.color, Colors.red);
      });

      test('default width is 1', () {
        final border = AppFieldStyles.border(color: Colors.blue);
        expect(border.borderSide.width, 1);
      });

      test('applies custom width', () {
        final border = AppFieldStyles.border(color: Colors.blue, width: 2);
        expect(border.borderSide.width, 2);
      });
    });
  });
}
