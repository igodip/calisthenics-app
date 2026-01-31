
import 'package:calisync/l10n/locale_controller.dart';
import 'package:calisync/pages/onboarding.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:calisync/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Supabase.initialize(
    url: 'https://jrqjysycoqhlnyufhliy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpycWp5c3ljb3FobG55dWZobGl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI0MzM0NTIsImV4cCI6MjA2ODAwOTQ1Mn0.3BVA-Ar9YtLGGO12Gt6NQkMl2cn18E_b48PGtlFxxCw',
  );
  final preferences = await SharedPreferences.getInstance();
  final storedTheme = AppTheme.themeTypeFromStorage(
    preferences.getString(ThemeController.storageKey),
  );
  final themeController = ThemeController(
    preferences: preferences,
    initialTheme: storedTheme,
  );
  final storedLocaleCode = preferences.getString(LocaleController.storageKey);
  final storedLocale = storedLocaleCode == null
      ? null
      : AppLocalizations.supportedLocales
          .where((locale) => locale.languageCode == storedLocaleCode)
          .cast<Locale?>()
          .firstWhere((locale) => locale != null, orElse: () => null);
  final localeController = LocaleController(
    preferences: preferences,
    initialLocale: storedLocale,
  );

  runApp(CalisthenicsApp(
    themeController: themeController,
    localeController: localeController,
  ));
}

class CalisthenicsApp extends StatelessWidget {
  const CalisthenicsApp({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  final ThemeController themeController;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ThemeControllerScope(
      controller: themeController,
      child: LocaleControllerScope(
        controller: localeController,
        child: AnimatedBuilder(
          animation: Listenable.merge([themeController, localeController]),
          builder: (context, _) {
            final theme = AppTheme.themeFor(themeController.themeType);
            return MaterialApp(
              onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
              theme: theme,
              darkTheme: theme,
              themeMode: ThemeMode.dark,
              locale: localeController.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const OnboardingGate(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
