import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/l10n/locale_controller.dart';
import 'package:calisync/main.dart' as app;
import 'package:calisync/pages/home_page.dart';
import 'package:calisync/pages/workout_plan_page.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:calisync/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'store_demo_backend.dart';

typedef CaptureScreen = Future<void> Function(String name);

/// Uses the production widget tree. Only authentication and HTTP data are faked.
Future<void> captureStoreScreens(
  WidgetTester tester, {
  required CaptureScreen capture,
}) async {
  SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true});
  final backend = StoreDemoBackend();
  debugPrint('Store capture: initializing demo backend');
  await tester.runAsync(() async {
    await Supabase.initialize(
      url: 'https://${StoreDemoBackend.host}',
      publishableKey: 'fixture-only-public-key',
      httpClient: backend.client,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
      ),
    );
    await Supabase.instance.client.auth.signInWithPassword(
      email: 'alex@example.invalid',
      password: 'fixture-only-not-a-password',
    );
  });
  final preferences = await SharedPreferences.getInstance();

  Future<void> settle() async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );
    expect(tester.takeException(), isNull);
    expect(backend.unexpectedRequests, isEmpty);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  }

  Future<void> openSection(String title) async {
    debugPrint('Store capture: opening $title');
    final home = find.byType(HomePage);
    final scaffold = find
        .descendant(of: home, matching: find.byType(Scaffold))
        .first;
    tester.state<ScaffoldState>(scaffold).openDrawer();
    await settle();
    final item = find.descendant(
      of: find.byType(Drawer),
      matching: find.widgetWithText(ListTile, title),
    );
    await tester.ensureVisible(item);
    await tester.tap(item);
    await settle();
  }

  try {
    for (final language in ['it', 'en']) {
      debugPrint('Store capture: loading $language home');
      backend.locale = language;
      final theme = ThemeController(
        preferences: preferences,
        initialTheme: AppThemeType.defaultTheme,
      );
      final locale = LocaleController(
        preferences: preferences,
        initialLocale: Locale(language),
      );
      // A fresh root avoids retaining the previous locale's queried content.
      await tester.pumpWidget(
        app.CalisthenicsApp(
          key: ValueKey(language),
          themeController: theme,
          localeController: locale,
        ),
      );
      await settle();
      final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)))!;
      expect(find.textContaining('Alex'), findsWidgets);
      expect(find.text(backend.planTitle), findsWidgets);
      await capture('$language/01-home');

      await openSection(l10n.workoutPlanTitle);
      expect(find.byType(WorkoutPlanPage), findsOneWidget);
      expect(find.text(backend.planTitle), findsWidgets);
      await capture('$language/02-training-plan');

      await openSection(l10n.profileMaxTestsTitle);
      expect(find.textContaining('Pull-up'), findsWidgets);
      await capture('$language/03-progress');

      await openSection(l10n.navGuides);
      expect(find.text('Push-up'), findsWidgets);
      await capture('$language/04-exercise-guides');

      await openSection(l10n.traineeFeedbackTitle);
      // Scroll to the real conversation card rather than screenshot an empty form.
      final reply = find.text(backend.coachMessage);
      await tester.ensureVisible(reply);
      await settle();
      await capture('$language/05-coach-feedback');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
    expect(backend.unexpectedRequests, isEmpty);
    debugPrint('Store capture: all ten screens completed');
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    // Supabase owns a real JSON isolate; dispose outside the widget fake clock.
    await tester.runAsync(() => Supabase.instance.dispose());
    backend.client.close();
    debugPrint('Store capture: cleanup completed');
  }
}
