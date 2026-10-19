import 'dart:convert';

import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/pages/timer_page.dart';
import 'package:calisync/pages/timer_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final awakeRequests = <bool>[];
  setUp(() {
    awakeRequests.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('calisync/timer_screen'),
          (call) async {
            expect(call.method, 'setKeepAwake');
            awakeRequests.add(call.arguments as bool);
            return null;
          },
        );
  });

  testWidgets(
    'dial animates progress and snaps when paused or motion disabled',
    (tester) async {
      Future<void> show(
        double progress, {
        bool animate = true,
        bool reducedMotion = false,
      }) => tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reducedMotion),
            child: Center(
              child: SizedBox.square(
                dimension: 240,
                child: WorkoutTimerDial(
                  progress: progress,
                  activeColor: Colors.blue,
                  animate: animate,
                ),
              ),
            ),
          ),
        ),
      );
      double value() => tester
          .widget<CircularProgressIndicator>(
            find.byKey(const ValueKey('workout-timer-progress')),
          )
          .value!;

      await show(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 425));
      expect(value(), closeTo(0.425 / 60, 0.00001));
      final beforeFrame = value();
      await tester.pump(const Duration(milliseconds: 16));
      expect(value() - beforeFrame, closeTo(0.016 / 60, 0.00001));
      // There must be no dead zone between 850ms and the next second.
      await tester.pump(const Duration(milliseconds: 500));
      expect(value(), closeTo(0.941 / 60, 0.00001));
      await show(0.3, animate: false);
      await tester.pump();
      expect(value(), 0.3);
      await tester.pump(const Duration(milliseconds: 200));
      expect(value(), 0.3);
      await show(0.8, reducedMotion: true);
      await tester.pump();
      expect(value(), 0.8);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('screen stays awake only while the foreground timer is running', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TimerPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(awakeRequests, isEmpty);
    final toggle = find.byKey(const ValueKey('workout-timer-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    expect(awakeRequests.last, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(awakeRequests.last, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(awakeRequests.last, isTrue);
    await tester.tap(toggle);
    await tester.pump();
    expect(awakeRequests.last, isFalse);
    await tester.tap(toggle);
    await tester.pump();
    expect(awakeRequests.last, isTrue);
    await tester.tap(find.byKey(const ValueKey('workout-timer-reset')));
    await tester.pump();
    expect(awakeRequests.last, isFalse);
    await tester.tap(toggle);
    await tester.pump();
    expect(awakeRequests.last, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(awakeRequests.last, isFalse);
  });

  testWidgets('finishing a restored timer releases the screen wake lock', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'timer_workout_session': jsonEncode({
        'mode': 0,
        'amrapMinutes': 1,
        'hasStarted': true,
        'isRunning': true,
        'sessionElapsedSeconds': 69,
        'lastWallSyncAt': DateTime.now().millisecondsSinceEpoch,
      }),
    });
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TimerPage(),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(awakeRequests.last, isTrue);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(awakeRequests.last, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workout timers open directly without the exercise timer', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TimerPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pull-ups'), findsNothing);
    expect(find.text('Exercise timer'), findsNothing);
    expect(find.text('AMRAP'), findsWidgets);
    expect(find.text('TABATA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workout timers fit a narrow phone and preserve timer state', (
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
    expect(find.text('Elapsed: 00:00'), findsNothing);

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
    // A running dial intentionally schedules frames continuously.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
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

    await tester.ensureVisible(workoutToggle);
    await tester.tap(workoutToggle);
    await tester.pump();
    expect(find.text('GET READY'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('00:06'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Minute 1'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('Elapsed: 00:00'), findsOneWidget);
  });
}
