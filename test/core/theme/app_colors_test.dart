import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultix/core/theme/app_colors.dart';

void main() {
  group('AppPalette', () {
    group('midnight palette', () {
      test('has correct name', () {
        expect(AppPalette.midnight.name, 'Midnight');
      });

      test('has correct primary color', () {
        expect(AppPalette.midnight.primary, const Color(0xFF222831));
      });

      test('has correct secondary color', () {
        expect(AppPalette.midnight.secondary, const Color(0xFF393E46));
      });

      test('has correct accent color', () {
        expect(AppPalette.midnight.accent, const Color(0xFF00ADB5));
      });

      test('has correct surface color', () {
        expect(AppPalette.midnight.surface, const Color(0xFFEEEEEE));
      });

      test('has correct error color', () {
        expect(AppPalette.midnight.error, const Color(0xFFE53935));
      });
    });

    group('sky palette', () {
      test('has correct name', () {
        expect(AppPalette.sky.name, 'Sky');
      });

      test('has correct primary color', () {
        expect(AppPalette.sky.primary, const Color(0xFF112D4E));
      });

      test('has correct secondary color', () {
        expect(AppPalette.sky.secondary, const Color(0xFF3F72AF));
      });

      test('has correct accent color', () {
        expect(AppPalette.sky.accent, const Color(0xFFDBE2EF));
      });

      test('has correct surface color', () {
        expect(AppPalette.sky.surface, const Color(0xFFF9F7F7));
      });

      test('has correct error color', () {
        expect(AppPalette.sky.error, const Color(0xFFD32F2F));
      });
    });

    group('all list', () {
      test('contains exactly 2 palettes', () {
        expect(AppPalette.all.length, 2);
      });

      test('contains midnight', () {
        expect(AppPalette.all, contains(AppPalette.midnight));
      });

      test('contains sky', () {
        expect(AppPalette.all, contains(AppPalette.sky));
      });
    });

    test('constructor creates palette with all required fields', () {
      const palette = AppPalette(
        name: 'Test',
        primary: Color(0xFF000001),
        secondary: Color(0xFF000002),
        accent: Color(0xFF000003),
        surface: Color(0xFF000004),
        error: Color(0xFF000005),
      );
      expect(palette.name, 'Test');
      expect(palette.primary, const Color(0xFF000001));
      expect(palette.secondary, const Color(0xFF000002));
      expect(palette.accent, const Color(0xFF000003));
      expect(palette.surface, const Color(0xFF000004));
      expect(palette.error, const Color(0xFF000005));
    });
  });
}
