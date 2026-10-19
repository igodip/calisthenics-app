import 'package:calisync/components/max_tests_dashboard.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/model/exercise_guide.dart';
import 'package:calisync/model/max_test.dart';
import 'package:calisync/pages/max_tests_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const guides = [
  ExerciseGuide(
    databaseId: 'pull',
    id: 'pull-up',
    name: 'Pull-up',
    difficulty: Difficulty.intermediate,
    focus: '',
    tip: '',
    description: '',
  ),
  ExerciseGuide(
    databaseId: 'dip',
    id: 'dips',
    name: 'Parallel-bar dip with a long exercise name',
    difficulty: Difficulty.intermediate,
    focus: '',
    tip: '',
    description: '',
  ),
];
final results = [
  MaxTest(
    id: 'latest',
    exerciseId: 'pull',
    exercise: 'pull-up',
    value: 8,
    unit: 'reps',
    recordedAt: DateTime(2026, 10, 20),
  ),
  MaxTest(
    id: 'best',
    exerciseId: 'pull',
    exercise: 'pull-up',
    value: 12,
    unit: 'reps',
    recordedAt: DateTime(2026, 10, 10),
  ),
  MaxTest(
    id: 'old',
    exerciseId: 'pull',
    exercise: 'pull-up',
    value: 10,
    unit: 'reps',
    recordedAt: DateTime(2025, 1, 1),
  ),
  MaxTest(
    id: 'dip',
    exerciseId: 'dip',
    exercise: 'dips',
    value: 20.5,
    unit: 'kg',
    recordedAt: DateTime(2026, 10, 19),
  ),
];

void main() {
  Future<void> open(
    WidgetTester tester,
    Widget child, {
    String locale = 'en',
    Size size = const Size(320, 640),
    double scale = 1,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'trainee sees complete history but never trainer notes or edit actions',
    (tester) async {
      await open(
        tester,
        MaxTestsDashboard(
          tests: results,
          guides: guides,
          historyExpanded: true,
          trainerNotes: const {'latest': 'PRIVATE'},
          onRefresh: () async {},
        ),
      );
      expect(find.byKey(const ValueKey('max-attempt-latest')), findsOneWidget);
      expect(find.byKey(const ValueKey('max-attempt-best')), findsOneWidget);
      expect(find.byKey(const ValueKey('max-attempt-old')), findsOneWidget);
      expect(find.text('PRIVATE'), findsNothing);
      expect(find.byKey(const ValueKey('max-tests-add')), findsNothing);
      expect(find.byKey(const ValueKey('max-notes-latest')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('categories and search find relevant exercises', (tester) async {
    await open(
      tester,
      MaxTestsDashboard(tests: results, guides: guides, onRefresh: () async {}),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('max-category-push')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('max-category-push')));
    await tester.pumpAndSettle();
    expect(find.text('Pull-up'), findsNothing);
    expect(find.text(guides.last.name), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('max-tests-search')));
    await tester.enterText(
      find.byKey(const ValueKey('max-tests-search')),
      'not in the catalog',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('No results match'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'trainer has visible add and notes actions with full historical records',
    (tester) async {
      MaxTest? edited, added, deleted;
      var add = false;
      await open(
        tester,
        MaxTestsDashboard(
          tests: results.take(3).toList(),
          guides: guides,
          historyExpanded: true,
          onRefresh: () async {},
          onAdd: () => add = true,
          onAddForExercise: (test) => added = test,
          onEditNotes: (test) => edited = test,
          onDelete: (test) => deleted = test,
          trainerNotes: const {'latest': 'Private form cue'},
        ),
      );
      await tester.tap(find.byKey(const ValueKey('max-tests-add')));
      expect(add, isTrue);
      final notes = find.byKey(const ValueKey('max-series-notes-latest'));
      await tester.ensureVisible(notes);
      await tester.pumpAndSettle();
      await tester.tap(notes);
      expect(edited?.id, 'latest');
      final delete = find.byKey(const ValueKey('max-delete-old'));
      await tester.ensureVisible(delete);
      await tester.pumpAndSettle();
      await tester.tap(delete);
      expect(deleted?.id, 'old');
      final perExerciseAdd = find.widgetWithIcon(
        TextButton,
        Icons.add_circle_outline,
      );
      await tester.ensureVisible(perExerciseAdd);
      await tester.pumpAndSettle();
      await tester.tap(perExerciseAdd);
      expect(added?.id, 'latest');
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['en', 'it', 'es']) {
    for (final size in [
      const Size(320, 568),
      const Size(568, 320),
      const Size(1100, 800),
    ]) {
      testWidgets('$locale max tests fit $size with large text', (
        tester,
      ) async {
        await open(
          tester,
          MaxTestsDashboard(
            tests: results,
            guides: guides,
            historyExpanded: true,
            onRefresh: () async {},
            onAdd: () {},
            onEditNotes: (_) {},
            onDelete: (_) {},
            trainerNotes: {
              'latest': List.filled(30, 'Long trainer-only note').join(' '),
            },
          ),
          locale: locale,
          size: size,
          scale: 2,
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('max-attempt-old')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('failed trainee loading offers retry and recovers', (
    tester,
  ) async {
    var requests = 0;
    await open(
      tester,
      MaxTestsContent(
        userId: 'trainee',
        displayName: 'Athlete',
        loadGuides: (_) async => guides,
        loadTests: () async {
          if (++requests == 1) throw StateError('offline');
          return results;
        },
      ),
    );
    expect(find.textContaining('Could not load max tests'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Pull-up'), findsOneWidget);
    expect(requests, 2);
  });

  testWidgets('catalog outage does not hide measurement history', (
    tester,
  ) async {
    await open(
      tester,
      MaxTestsContent(
        userId: 'trainee',
        displayName: 'Athlete',
        loadGuides: (_) async => throw StateError('catalog unavailable'),
        loadTests: () async => results,
      ),
    );
    expect(find.text('pull-up'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'period filters label partial histories and selected-period bests accurately',
    (tester) async {
      final now = DateTime.now();
      final attempts = [
        MaxTest(
          id: 'recent',
          exerciseId: 'pull',
          exercise: 'pull-up',
          value: 8,
          unit: 'reps',
          recordedAt: now.subtract(const Duration(days: 1)),
        ),
        MaxTest(
          id: 'older-best',
          exerciseId: 'pull',
          exercise: 'pull-up',
          value: 20,
          unit: 'reps',
          recordedAt: now.subtract(const Duration(days: 100)),
        ),
      ];
      await open(
        tester,
        MaxTestsDashboard(
          tests: attempts,
          guides: guides,
          historyExpanded: true,
          onRefresh: () async {},
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 1 month').last);
      await tester.pumpAndSettle();
      expect(find.text('Best in selected period'), findsOneWidget);
      expect(find.text('History in selected period (1)'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('max-attempt-older-best')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('max-attempt-recent')), findsOneWidget);
    },
  );

  testWidgets(
    'trainee layout fits actual Home padding with doubled Italian text',
    (tester) async {
      await open(
        tester,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: MaxTestsContent(
            userId: 'trainee',
            displayName: 'Athlete',
            historyExpanded: true,
            loadGuides: (_) async => guides,
            loadTests: () async => results,
          ),
        ),
        locale: 'it',
        size: const Size(320, 568),
        scale: 2,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('max-attempt-old')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
