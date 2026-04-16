import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'app_feature_colors.dart';

class AppThemeNotifier extends ChangeNotifier {
  static const _themeKey = 'setting_theme';
  static const _localeKey = 'setting_locale';
  static const _showViKey = 'setting_show_vi';

  AppPalette _palette;
  Locale _locale;
  bool _showVietnamese;

  AppThemeNotifier({
    AppPalette palette = AppPalette.midnight,
    Locale locale = const Locale('en'),
    bool showVietnamese = true,
  }) : _palette = palette,
       _locale = locale,
       _showVietnamese = showVietnamese {
    AppFeatureColors.bindPalette(_palette);
  }

  AppPalette get palette => _palette;
  Locale get locale => _locale;
  bool get showVietnamese => _showVietnamese;

  static Future<AppThemeNotifier> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey);
    final localeCode = prefs.getString(_localeKey);
    final showVi = prefs.getBool(_showViKey) ?? true;

    final palette = AppPalette.all.firstWhere(
      (p) => p.name == themeName,
      orElse: () => AppPalette.midnight,
    );
    final locale = Locale(localeCode ?? 'en');
    return AppThemeNotifier(
      palette: palette,
      locale: locale,
      showVietnamese: showVi,
    );
  }

  void setTheme(AppPalette palette) {
    if (_palette == palette) return;
    _palette = palette;
    AppFeatureColors.bindPalette(_palette);
    notifyListeners();
    _persist();
  }

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    _persist();
  }

  void setShowVietnamese(bool value) {
    if (_showVietnamese == value) return;
    _showVietnamese = value;
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _palette.name);
    await prefs.setString(_localeKey, _locale.languageCode);
    await prefs.setBool(_showViKey, _showVietnamese);
  }
}

class AppThemeProvider extends InheritedNotifier<AppThemeNotifier> {
  const AppThemeProvider({
    super.key,
    required AppThemeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppPalette of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppThemeProvider>()!
        .notifier!
        .palette;
  }

  static Locale localeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppThemeProvider>()!
        .notifier!
        .locale;
  }

  static AppThemeNotifier notifierOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppThemeProvider>()!
        .notifier!;
  }
}
