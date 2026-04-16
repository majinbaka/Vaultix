import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/theme_controller.dart';
import '../features/password_manager/master_password_screen.dart';
import '../l10n/app_localizations.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.settings});

  final AppThemeNotifier settings;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AppThemeNotifier _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() => setState(() {});

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeProvider(
      notifier: _settings,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _settings.locale,
        theme: ThemeData(
          fontFamily: GoogleFonts.inter().fontFamily,
          textTheme: GoogleFonts.interTextTheme(),
          primaryTextTheme: GoogleFonts.interTextTheme(),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: GoogleFonts.inter().fontFamily,
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          primaryTextTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().primaryTextTheme,
          ),
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MasterPasswordScreen(),
      ),
    );
  }
}
