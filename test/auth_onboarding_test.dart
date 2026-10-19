import 'package:calisync/components/auth_visuals.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double contrast(Color first, Color second) {
    final a = first.computeLuminance();
    final b = second.computeLuminance();
    return a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
  }

  test('auth text, buttons and input outlines retain clear contrast', () {
    expect(
      contrast(Colors.white, AuthVisuals.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AuthVisuals.muted, AuthVisuals.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AuthVisuals.mint, AuthVisuals.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AuthVisuals.inputOutline, AuthVisuals.inputBackground),
      greaterThanOrEqualTo(3),
    );
    expect(
      contrast(AuthVisuals.inputOutline, AuthVisuals.background),
      greaterThanOrEqualTo(3),
    );
  });

  testWidgets('artwork retains a light tint with the fade below the subject', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthArtwork(
            asset: 'assets/auth/rings.webp',
            height: 240,
            subdued: true,
          ),
        ),
      ),
    );
    final overlay = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(AuthArtwork),
        matching: find.byType(DecoratedBox),
      ),
    );
    final gradient =
        (overlay.decoration as BoxDecoration).gradient! as LinearGradient;
    expect(gradient.colors[0].a, lessThanOrEqualTo(.15));
    expect(gradient.colors[1].a, lessThanOrEqualTo(.10));
    expect(gradient.stops![1], greaterThanOrEqualTo(.7));
    expect(gradient.colors.last, AuthVisuals.background);
  });

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

  testWidgets(
    'onboarding keeps header and footer pinned while content scrolls',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await open(tester, scale: 2);
      final header = find.byKey(const ValueKey('onboarding-header'));
      final footer = find.byKey(const ValueKey('onboarding-footer'));
      final headerRect = tester.getRect(header);
      final footerRect = tester.getRect(footer);
      expect(headerRect.top, 0);
      expect(footerRect.bottom, 568);
      await tester.drag(find.byType(PageView), const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(tester.getRect(header), headerRect);
      expect(tester.getRect(footer), footerRect);
      expect(tester.takeException(), isNull);
    },
  );

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
