import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/pages/timer_components.dart';
import 'package:calisync/pages/timer_page.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> openTimer(WidgetTester tester, Locale locale, double scale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      theme: AppTheme.theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const TimerPage(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    for (final scenario in const [
      (Size(280, 568), 1.0),
      (Size(320, 568), 2.0),
      (Size(320, 568), 3.0),
      (Size(844, 390), 1.0),
      (Size(1024, 768), 1.0),
      (Size(1280, 900), 3.0),
    ]) {
      testWidgets(
        'all timer modes fit $locale ${scenario.$1} scale ${scenario.$2}',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          await tester.binding.setSurfaceSize(scenario.$1);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await openTimer(tester, locale, scenario.$2);
          for (final mode in WorkoutTimerMode.values) {
            final selector = find.byKey(ValueKey('timer-mode-${mode.name}'));
            await tester.ensureVisible(selector);
            await tester.tap(selector);
            await tester.pumpAndSettle();
            final confirm = find.byKey(const ValueKey('timer-change-confirm'));
            if (confirm.evaluate().isNotEmpty) {
              await tester.ensureVisible(confirm);
              await tester.tap(confirm);
              await tester.pumpAndSettle();
            }
            final dial = find.byKey(const ValueKey('timer-dial-container'));
            expect(
              tester.getSize(dial).width,
              lessThanOrEqualTo(scenario.$1.width - 24),
            );
            final toggle = find.byKey(const ValueKey('workout-timer-toggle'));
            await tester.ensureVisible(toggle);
            await tester.pumpAndSettle();
            expect(toggle.hitTestable(), findsOneWidget);
            for (final setting in find.byType(WorkoutTimerSetting).evaluate()) {
              final increase = find.descendant(
                of: find.byWidget(setting.widget),
                matching: find.byIcon(Icons.add),
              );
              await tester.ensureVisible(increase);
              await tester.tap(increase);
              await tester.pumpAndSettle();
            }
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }

  testWidgets('running timer retains time and reps when switching layouts', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await openTimer(tester, const Locale('en'), 1);
    final add = find.byKey(const ValueKey('amrap-add-rep'));
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pump();
    final toggle = find.byKey(const ValueKey('workout-timer-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:07'), findsOneWidget);
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    await tester.pump();
    expect(find.byKey(const ValueKey('timer-wide-layout')), findsOneWidget);
    expect(find.text('00:07'), findsOneWidget);
    expect(find.text('Reps: 1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:05'), findsOneWidget);
    await tester.binding.setSurfaceSize(const Size(320, 720));
    await tester.pump();
    expect(find.byKey(const ValueKey('timer-wide-layout')), findsNothing);
    expect(find.text('00:05'), findsOneWidget);
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
