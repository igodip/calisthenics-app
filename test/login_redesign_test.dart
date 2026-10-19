import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/components/auth_visuals.dart';
import 'package:calisync/pages/login_page.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.app_links/events'),
          (_) async => null,
        );
  });

  Future<void> open(
    WidgetTester tester, {
    bool login = true,
    double scale = 1,
    double keyboard = 0,
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        theme: AppTheme.theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: child!,
        ),
        home: LoginPage(initialLoginMode: login),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('signup entry keeps confirmation and privacy notice', (
    tester,
  ) async {
    await open(tester, login: false);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.textContaining('Before creating an account'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    await tester.ensureVisible(find.text('Already have an account? Sign in'));
    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signup header and footer remain pinned while the form scrolls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, login: false);
    final header = find.byKey(const ValueKey('auth-header'));
    final footer = find.byKey(const ValueKey('auth-footer'));
    final headerRect = tester.getRect(header);
    final footerRect = tester.getRect(footer);
    expect(headerRect.top, 0);
    expect(footerRect.bottom, 568);
    await tester.drag(
      find.byKey(const ValueKey('auth-content')),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    expect(tester.getRect(header), headerRect);
    expect(tester.getRect(footer), footerRect);
    expect(find.text('Privacy policy').hitTestable(), findsOneWidget);
    expect(find.byType(FilledButton).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password visibility and empty submission remain usable', (
    tester,
  ) async {
    await open(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isFalse,
    );
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(LoginPage));
    expect(
      find.text(AppLocalizations.of(context)!.missingFieldsError),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('small login viewport scrolls with keyboard and large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, scale: 2, keyboard: 240);
    expect(find.byType(AuthArtwork), findsNothing);
    await tester.ensureVisible(find.byType(FilledButton));
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(390, 844), const Size(1024, 768)]) {
    for (final login in [true, false]) {
      testWidgets(
        '${login ? 'login' : 'signup'} centers artwork and aligns content at $size',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await open(tester, login: login);
          final art = tester.widget<AuthArtwork>(find.byType(AuthArtwork));
          expect(art.fit, BoxFit.contain);
          expect(art.subdued, isTrue);
          final image = find.descendant(
            of: find.byType(AuthArtwork),
            matching: find.byType(Image),
          );
          expect(tester.getCenter(image).dx, closeTo(size.width / 2, 0.1));
          final contentWidth = size.width > AuthVisuals.maxContentWidth
              ? AuthVisuals.maxContentWidth
              : size.width;
          final inset =
              (size.width - contentWidth) / 2 + AuthVisuals.horizontalPadding;
          final fields = find.byType(TextField);
          for (var index = 0; index < fields.evaluate().length; index++) {
            expect(tester.getTopLeft(fields.at(index)).dx, closeTo(inset, 0.1));
            expect(
              tester.getSize(fields.at(index)).width,
              closeTo(contentWidth - 48, 0.1),
            );
          }
          final title = find
              .text(login ? 'Welcome back.' : 'Create account')
              .first;
          final titleWidget = tester.widget<Text>(title);
          expect(
            titleWidget.style,
            AuthVisuals.headingStyle(tester.element(title)),
          );
          await tester.ensureVisible(find.byType(FilledButton));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final language in ['en', 'it', 'es']) {
    testWidgets('$language signup fits large text and a landscape keyboard', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(568, 320));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await open(
        tester,
        login: false,
        locale: Locale(language),
        scale: 2,
        keyboard: 160,
      );
      expect(find.byType(AuthArtwork), findsNothing);
      await tester.ensureVisible(find.byType(TextField).last);
      await tester.ensureVisible(find.byType(FilledButton));
      expect(tester.takeException(), isNull);
    });
  }
}
