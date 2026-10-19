import 'dart:io';

import 'package:calisync/components/exercise_image_gallery.dart';
import 'package:calisync/data/exercise_illustrations.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all 15 audited catalog slugs have distinct bundled pictures', () {
    const auditedSlugs = {
      'pull-up',
      'chin-up',
      'push-up',
      'bodyweight-squat',
      'glute-bridge',
      'hanging-leg-raise',
      'muscle-up',
      'straight-bar-dip',
      'dips',
      'australian-row',
      'pike-push-up',
      'hollow-body-hold',
      'plank',
      'l-sit',
      'handstand-hold',
    };
    expect(ExerciseIllustrations.bySlug.keys.toSet(), auditedSlugs);
    final allAssets = ExerciseIllustrations.bySlug.values
        .expand((paths) => paths)
        .toList();
    expect(allAssets.toSet().length, allAssets.length);
    for (final path in allAssets) {
      expect(File(path).existsSync(), isTrue, reason: path);
      expect(File(path).lengthSync(), greaterThan(0), reason: path);
    }
  });

  test('translation-independent matching does not infer custom variants', () {
    expect(ExerciseIllustrations.forSlug(' PUSH-UP '), isNotEmpty);
    expect(ExerciseIllustrations.forSlug('push up ISO'), isEmpty);
    expect(ExerciseIllustrations.forSlug('unknown-future-exercise'), isEmpty);
    expect(ExerciseIllustrations.forSlug(''), isEmpty);
  });

  Future<void> open(
    WidgetTester tester, {
    List<String> assets = const ['assets/exercises/push-up.webp'],
    String locale = 'en',
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseImageGallery(
              exerciseName: 'Push-up',
              assets: assets,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens an offline zoomable picture and returns to the guide', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('Push-up'), findsOneWidget);
    expect(find.textContaining('Pinch to zoom'), findsOneWidget);
    expect(
      tester.widget<InteractiveViewer>(find.byType(InteractiveViewer)).maxScale,
      4,
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports navigation when an exercise has several pictures', (
    tester,
  ) async {
    await open(
      tester,
      assets: const ['assets/logo.png', 'assets/exercises/push-up.webp'],
    );
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('1 of 2'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('1 of 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final locale in ['en', 'it', 'es']) {
    testWidgets('$locale gallery supports a narrow phone and large text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await open(tester, locale: locale, scale: 2);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('unavailable asset gives a readable fallback', (tester) async {
    await open(tester, assets: const ['assets/exercises/missing.webp']);
    expect(find.text('Picture unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
