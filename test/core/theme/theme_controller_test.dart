import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultix/core/theme/app_colors.dart';
import 'package:vaultix/core/theme/theme_controller.dart';

void main() {
  group('AppThemeNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('default constructor uses midnight palette', () {
      final notifier = AppThemeNotifier();
      expect(notifier.palette, AppPalette.midnight);
    });

    test('default constructor uses en locale', () {
      final notifier = AppThemeNotifier();
      expect(notifier.locale, const Locale('en'));
    });

    test('default constructor sets showVietnamese to true', () {
      final notifier = AppThemeNotifier();
      expect(notifier.showVietnamese, true);
    });

    test('constructor accepts custom palette', () {
      final notifier = AppThemeNotifier(palette: AppPalette.sky);
      expect(notifier.palette, AppPalette.sky);
    });

    test('constructor accepts custom locale', () {
      final notifier = AppThemeNotifier(locale: const Locale('vi'));
      expect(notifier.locale, const Locale('vi'));
    });

    test('constructor accepts showVietnamese false', () {
      final notifier = AppThemeNotifier(showVietnamese: false);
      expect(notifier.showVietnamese, false);
    });

    test('setTheme changes palette and notifies', () {
      final notifier = AppThemeNotifier();
      var notified = false;
      notifier.addListener(() => notified = true);

      notifier.setTheme(AppPalette.sky);

      expect(notifier.palette, AppPalette.sky);
      expect(notified, true);
    });

    test('setTheme with same palette does not notify', () {
      final notifier = AppThemeNotifier(palette: AppPalette.midnight);
      var notified = false;
      notifier.addListener(() => notified = true);

      notifier.setTheme(AppPalette.midnight);

      expect(notified, false);
    });

    test('setLocale changes locale and notifies', () {
      final notifier = AppThemeNotifier();
      var notified = false;
      notifier.addListener(() => notified = true);

      notifier.setLocale(const Locale('vi'));

      expect(notifier.locale, const Locale('vi'));
      expect(notified, true);
    });

    test('setLocale with same locale does not notify', () {
      final notifier = AppThemeNotifier(locale: const Locale('en'));
      var notified = false;
      notifier.addListener(() => notified = true);

      notifier.setLocale(const Locale('en'));

      expect(notified, false);
    });

    test('setShowVietnamese changes value and notifies', () {
      final notifier = AppThemeNotifier();
      var notified = false;
      notifier.addListener(() => notified = true);

      notifier.setShowVietnamese(false);

      expect(notifier.showVietnamese, false);
      expect(notified, true);
    });

    test('setShowVietnamese with same value does not notify', () {
      final notifier = AppThemeNotifier(showVietnamese: true);
      var notified = false;
      notifier.addListener(() => notified = true);

      notifier.setShowVietnamese(true);

      expect(notified, false);
    });

    group('load()', () {
      test('loads with default values when prefs are empty', () async {
        SharedPreferences.setMockInitialValues({});
        final notifier = await AppThemeNotifier.load();
        expect(notifier.palette, AppPalette.midnight);
        expect(notifier.locale, const Locale('en'));
        expect(notifier.showVietnamese, true);
      });

      test('loads saved theme name', () async {
        SharedPreferences.setMockInitialValues({
          'setting_theme': 'Sky',
        });
        final notifier = await AppThemeNotifier.load();
        expect(notifier.palette, AppPalette.sky);
      });

      test('falls back to midnight for unknown theme name', () async {
        SharedPreferences.setMockInitialValues({
          'setting_theme': 'Unknown',
        });
        final notifier = await AppThemeNotifier.load();
        expect(notifier.palette, AppPalette.midnight);
      });

      test('loads saved locale', () async {
        SharedPreferences.setMockInitialValues({
          'setting_locale': 'vi',
        });
        final notifier = await AppThemeNotifier.load();
        expect(notifier.locale, const Locale('vi'));
      });

      test('loads saved showVietnamese false', () async {
        SharedPreferences.setMockInitialValues({
          'setting_show_vi': false,
        });
        final notifier = await AppThemeNotifier.load();
        expect(notifier.showVietnamese, false);
      });
    });

    group('persist()', () {
      test('setTheme persists to shared preferences', () async {
        SharedPreferences.setMockInitialValues({});
        final notifier = AppThemeNotifier();
        notifier.setTheme(AppPalette.sky);

        // Allow microtasks to settle
        await Future.delayed(Duration.zero);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('setting_theme'), 'Sky');
      });

      test('setLocale persists to shared preferences', () async {
        SharedPreferences.setMockInitialValues({});
        final notifier = AppThemeNotifier();
        notifier.setLocale(const Locale('vi'));

        await Future.delayed(Duration.zero);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('setting_locale'), 'vi');
      });

      test('setShowVietnamese persists to shared preferences', () async {
        SharedPreferences.setMockInitialValues({});
        final notifier = AppThemeNotifier();
        notifier.setShowVietnamese(false);

        await Future.delayed(Duration.zero);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('setting_show_vi'), false);
      });
    });
  });
}
