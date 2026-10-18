import 'package:calisync/components/auth_visuals.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double scale = 1,
    VoidCallback? finish,
    VoidCallback? signup,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: OnboardingPage(
          onFinish: finish ?? () {},
          onCreateAccount: signup,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'aligned pages route completion to signup and allow back navigation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var signups = 0;
      var logins = 0;
      await open(tester, finish: () => logins++, signup: () => signups++);
      final startY = tester
          .getTopLeft(find.text('Build strength.\nMaster control.'))
          .dy;
      final buttonY = tester.getTopLeft(find.byType(FilledButton)).dy;
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('See your\nprogress.')).dy, startY);
      expect(tester.getTopLeft(find.byType(FilledButton)).dy, buttonY);
      expect(
        find.byWidgetPredicate(
          (w) => w is AuthArtwork && w.asset.endsWith('handstand.webp'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Make training\na habit.')).dy,
        startY,
      );
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('See your\nprogress.'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      expect(signups, 1);
      expect(logins, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('skip and existing-account entry do not select signup', (
    tester,
  ) async {
    var logins = 0;
    var signups = 0;
    await open(tester, finish: () => logins++, signup: () => signups++);
    await tester.tap(find.text('Skip'));
    await tester.tap(find.text('Already have an account? Sign in'));
    expect(logins, 2);
    expect(signups, 0);
  });

  for (final language in ['en', 'it', 'es']) {
    testWidgets('$language supports small screens with large text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await open(tester, locale: Locale(language), scale: 2);
      expect(tester.takeException(), isNull);
      for (var step = 0; step < 2; step++) {
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
