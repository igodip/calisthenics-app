import 'package:calisync/l10n/app_localizations.dart';
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
  }) async {
    await tester.pumpWidget(
      MaterialApp(
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
    await tester.ensureVisible(find.byType(FilledButton));
    expect(tester.takeException(), isNull);
  });
}
