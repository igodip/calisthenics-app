import 'dart:math' as math;

import 'package:calisync/components/first_login_pushup.dart';
import 'package:calisync/components/home_mascot_setting.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    HomeMascotSettings.enabled.value = false;
    SharedPreferences.setMockInitialValues({
      HomeMascotSettings.storageKey: true,
    });
  });

  Future<void> open(
    WidgetTester tester,
    String userId, {
    bool reducedMotion = false,
    Future<bool> Function()? loadAura,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reducedMotion),
          child: Scaffold(
            bottomNavigationBar: FirstLoginPushup(
              key: ValueKey(userId),
              userId: userId,
              loadAura: loadAura,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Finder character() => find.byKey(const ValueKey('first-login-pushup'));
  WelcomeExercisePainter painter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: character(),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter!
          as WelcomeExercisePainter;

  testWidgets(
    'final-week status gives the athlete an aura, including a static reduced-motion pose',
    (tester) async {
      await open(
        tester,
        'athlete',
        reducedMotion: true,
        loadAura: () async => true,
      );
      await tester.pump();
      expect(painter(tester).aura, isTrue);
      expect(painter(tester).progress, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('failed final-week lookup leaves the ordinary athlete working', (
    tester,
  ) async {
    await open(
      tester,
      'athlete',
      loadAura: () async => throw StateError('offline'),
    );
    await tester.pump();
    expect(painter(tester).aura, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disabled mascot does not fetch training information', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var queries = 0;
    await open(
      tester,
      'athlete',
      loadAura: () async {
        queries++;
        return true;
      },
    );
    expect(character(), findsNothing);
    expect(queries, 0);
  });

  testWidgets('keeps animating indefinitely when enabled', (tester) async {
    await open(tester, 'athlete');
    expect(character(), findsOneWidget);
    expect(tester.getSize(character()).height, 56);
    final initial = painter(tester).progress;
    await tester.pump(const Duration(milliseconds: 500));
    expect(painter(tester).progress, greaterThan(initial));
    await tester.pump(const Duration(seconds: 9));
    expect(character(), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(character(), findsOneWidget);
    await tester.pump(const Duration(minutes: 5));
    expect(character(), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await open(tester, 'athlete');
    expect(character(), findsOneWidget);
    await open(tester, 'another-athlete');
    expect(character(), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('restarts after each unlock even with the old seen flag', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'home_pushup_seen_athlete': true,
      HomeMascotSettings.storageKey: true,
    });
    await open(tester, 'athlete');
    var previousExercise = painter(tester).exercise;
    await tester.pump(const Duration(seconds: 12));
    expect(character(), findsOneWidget);
    for (var unlock = 0; unlock < 2; unlock++) {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(character(), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(character(), findsOneWidget);
      expect(painter(tester).exercise, isNot(previousExercise));
      previousExercise = painter(tester).exercise;
      expect(painter(tester).progress, 0);
      await tester.pump(const Duration(milliseconds: 500));
      expect(painter(tester).progress, greaterThan(0));
      await tester.pump(const Duration(seconds: 10));
      expect(character(), findsOneWidget);
    }
  });

  testWidgets(
    'reduced motion shows a still character without animation frames',
    (tester) async {
      await open(tester, 'athlete', reducedMotion: true);
      expect(character(), findsOneWidget);
      expect(painter(tester).progress, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(painter(tester).progress, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pump(const Duration(seconds: 7));
      expect(character(), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(character(), findsOneWidget);
    },
  );

  test(
    'random selection includes all exercises and avoids consecutive repeats',
    () {
      final random = math.Random(42);
      WelcomeExercise? previous;
      final selected = <WelcomeExercise>{};
      for (var appearance = 0; appearance < 100; appearance++) {
        final exercise = chooseWelcomeExercise(random, previous: previous);
        expect(exercise, isNot(previous));
        selected.add(exercise);
        previous = exercise;
      }
      expect(selected, containsAll(WelcomeExercise.values));
    },
  );

  testWidgets('all five exercises paint throughout a full repetition', (
    tester,
  ) async {
    for (final exercise in WelcomeExercise.values) {
      for (final progress in [0.0, .05, .1, .15, .2]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: CustomPaint(
                size: const Size(110, 48),
                painter: WelcomeExercisePainter(
                  exercise: exercise,
                  progress: progress,
                  color: Colors.green,
                  floorColor: Colors.grey,
                  aura: true,
                ),
              ),
            ),
          ),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: '$exercise at $progress',
        );
      }
    }
  });

  testWidgets('no signed-in account means no character or saved flag', (
    tester,
  ) async {
    await open(tester, '');
    expect(character(), findsNothing);
    expect((await SharedPreferences.getInstance()).getKeys(), {
      HomeMascotSettings.storageKey,
    });
  });

  testWidgets(
    'defaults off and responds immediately to saved setting changes',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await open(tester, 'athlete');
      expect(character(), findsNothing);
      await HomeMascotSettings.setEnabled(true);
      await tester.pump();
      expect(character(), findsOneWidget);
      expect(
        (await SharedPreferences.getInstance()).getBool(
          HomeMascotSettings.storageKey,
        ),
        isTrue,
      );
      await HomeMascotSettings.setEnabled(false);
      await tester.pump();
      expect(character(), findsNothing);
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets('settings switch defaults off and saves the selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HomeMascotSetting()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
    expect(
      (await SharedPreferences.getInstance()).getBool(
        HomeMascotSettings.storageKey,
      ),
      isTrue,
    );
  });
}
