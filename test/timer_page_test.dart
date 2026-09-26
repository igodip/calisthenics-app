import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/pages/timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('exercise timer prepares and resumes after page recreation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const app = MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TimerPage(),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final toggle = find.byKey(const ValueKey('exercise-timer-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    expect(find.text('GET READY'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('00:06'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('GET READY'), findsOneWidget);
    expect(find.text('00:06'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workout timers are separate and fit a narrow phone', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TimerPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.text('Pull-ups'), findsWidgets);
    await tester.tap(find.text('Workout timers'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.text('Pull-ups'), findsNothing);
    expect(find.text('AMRAP'), findsWidgets);
    expect(find.text('EMOM'), findsOneWidget);
    expect(find.text('FOR TIME'), findsOneWidget);
    expect(find.text('TABATA'), findsOneWidget);
    expect(find.text('Reps: 0'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('amrap-add-rep')));
    await tester.pump();
    expect(find.text('Reps: 1'), findsOneWidget);

    final workoutToggle = find.byKey(const ValueKey('workout-timer-toggle'));
    await tester.ensureVisible(workoutToggle);
    await tester.tap(workoutToggle);
    await tester.pump();
    expect(find.text('GET READY'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('00:06'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TimerPage(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Workout timers'));
    await tester.pumpAndSettle();
    expect(find.text('GET READY'), findsOneWidget);
    expect(find.text('00:06'), findsOneWidget);
    expect(find.text('Reps: 1'), findsOneWidget);

    await tester.ensureVisible(workoutToggle);
    await tester.tap(workoutToggle);
    await tester.pump();

    await tester.tap(find.text('EMOM'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'If you change timers, you will lose the progress on the current timer.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('timer-change-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('00:06'), findsOneWidget);
    expect(find.text('Reps: 1'), findsOneWidget);

    await tester.tap(find.text('EMOM'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('timer-change-confirm')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('As long as possible'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
  });
}
