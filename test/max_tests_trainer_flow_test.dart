import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/model/exercise_guide.dart';
import 'package:calisync/trainer/pages/trainer_program_page.dart';
import 'package:calisync/trainer/components/trainer_trainee_card.dart';
import 'package:calisync/components/max_tests_dashboard.dart';
import 'package:calisync/trainer/trainer_models.dart';
import 'package:calisync/trainer/trainer_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final trainee = TrainerTrainee(
  id: 'athlete',
  name: 'Athlete',
  weight: null,
  height: null,
  paid: true,
  paymentAmount: null,
  coachTip: '',
  trainerNotes: '',
  completedExercises: 0,
  totalExercises: 0,
);
const guide = ExerciseGuide(
  databaseId: 'catalog-pull',
  id: 'pull-up',
  name: 'Pull-up with a deliberately long catalog exercise name',
  difficulty: Difficulty.intermediate,
  focus: '',
  tip: '',
  description: '',
);

class MemoryRepository extends Fake implements TrainerRepository {
  final rows = <Map<String, dynamic>>[
    {
      'id': 'existing',
      'exercise_id': 'catalog-pull',
      'exercise': 'pull-up',
      'value': 10,
      'unit': 'reps',
      'recorded_at': '2026-10-10',
      'trainer_notes': 'Original private note',
    },
  ];
  String? savedNotes;
  Map<String, Object?>? added;
  bool deleted = false;

  @override
  Future<TrainerProgramData> loadProgram(
    TrainerTrainee trainee,
    List<TrainerTrainee> allTrainees,
  ) async => TrainerProgramData(
    plans: const [],
    days: const [],
    maxTests: rows.toList(),
    weightLogs: const [],
    heightLogs: const [],
    payments: const [],
    feedback: const [],
  );

  @override
  Future<void> addMaxTest(
    String traineeId, {
    required String? exerciseId,
    required String exercise,
    required double value,
    required String unit,
    required DateTime recordedAt,
    String notes = '',
  }) async {
    added = {
      'exercise_id': exerciseId,
      'exercise': exercise,
      'value': value,
      'unit': unit,
      'notes': notes,
    };
    rows.insert(0, {
      'id': 'new',
      'exercise_id': exerciseId,
      'exercise': exercise,
      'value': value,
      'unit': unit,
      'recorded_at': recordedAt.toIso8601String(),
      'trainer_notes': notes,
    });
  }

  @override
  Future<void> saveMaxTestTrainerNotes(Object id, String notes) async {
    savedNotes = notes;
    rows.firstWhere((row) => row['id'] == id)['trainer_notes'] = notes;
  }

  @override
  Future<void> deleteMaxTest(Object id) async {
    deleted = true;
    rows.removeWhere((row) => row['id'] == id);
  }
}

void main() {
  testWidgets('athlete card offers a direct max-tests shortcut', (
    tester,
  ) async {
    var opened = false;
    var openedProgram = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(
            children: [
              TrainerTraineeCard(
                trainee: trainee,
                onOpen: () => openedProgram = true,
                onOpenMaxTests: () => opened = true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Max tests'));
    expect(opened, isTrue);
    expect(openedProgram, isFalse);
  });

  Future<void> open(
    WidgetTester tester,
    MemoryRepository repository, {
    String locale = 'en',
    double scale = 1,
    double keyboard = 0,
    bool catalogUnavailable = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: child!,
        ),
        home: TrainerProgramPage(
          trainee: trainee,
          allTrainees: [trainee],
          repository: repository,
          onTraineeChanged: (_) {},
          initialTab: TrainerProgramTab.maxTests,
          loadExerciseGuides: (_) async {
            if (catalogUnavailable) throw StateError('offline');
            return [guide];
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> reach(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('program trophy shortcut reaches max tests from another tab', (
    tester,
  ) async {
    await open(tester, MemoryRepository());
    final overview = find.widgetWithText(Tab, 'Overview');
    await reach(tester, overview);
    await tester.tap(overview);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TabBar>(find.byType(TabBar)).controller!.index,
      TrainerProgramTab.overview.index,
    );
    await tester.tap(find.byKey(const ValueKey('trainer-max-tests-shortcut')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TabBar>(find.byType(TabBar)).controller!.index,
      TrainerProgramTab.maxTests.index,
    );
    expect(find.byType(MaxTestsDashboard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'trainer adds a prefilled exercise with decimal result and private notes',
    (tester) async {
      final repository = MemoryRepository();
      await open(tester, repository);
      final add = find.widgetWithIcon(TextButton, Icons.add_circle_outline);
      await reach(tester, add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButtonFormField<Object>>(
              find.byKey(const ValueKey('max-test-exercise')),
            )
            .initialValue,
        guide,
      );
      await reach(tester, find.byKey(const ValueKey('max-test-value')));
      await tester.enterText(
        find.byKey(const ValueKey('max-test-value')),
        '-1',
      );
      await tester.tap(find.byKey(const ValueKey('max-test-save')));
      await tester.pumpAndSettle();
      expect(repository.added, isNull);
      expect(find.text('Enter a value greater than zero.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('max-test-value')),
        '12,5',
      );
      await reach(tester, find.byKey(const ValueKey('max-test-private-notes')));
      await tester.enterText(
        find.byKey(const ValueKey('max-test-private-notes')),
        'Private form cue',
      );
      await tester.tap(find.byKey(const ValueKey('max-test-save')));
      await tester.pumpAndSettle();
      expect(repository.added?['value'], 12.5);
      expect(repository.added?['exercise_id'], 'catalog-pull');
      expect(repository.added?['unit'], 'reps');
      expect(repository.added?['notes'], 'Private form cue');
      expect(find.text('Private form cue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('trainer can cancel, edit, and clear private notes', (
    tester,
  ) async {
    final repository = MemoryRepository();
    await open(tester, repository);
    final notes = find.byKey(const ValueKey('max-series-notes-existing'));
    await reach(tester, notes);
    await tester.tap(notes);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Unsaved',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(repository.savedNotes, isNull);
    await reach(tester, notes);
    await tester.tap(notes);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Updated note',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(repository.savedNotes, 'Updated note');
    expect(find.text('Updated note'), findsOneWidget);
    await reach(tester, notes);
    await tester.tap(notes);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      '',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(repository.savedNotes, '');
    expect(find.text('Updated note'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trainer deletion requires confirmation', (tester) async {
    final repository = MemoryRepository();
    await open(tester, repository);
    final history = find.text('Full history (1)');
    await reach(tester, history);
    await tester.tap(history);
    await tester.pumpAndSettle();
    final delete = find.byKey(const ValueKey('max-delete-existing'));
    await reach(tester, delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(repository.deleted, isFalse);
    await reach(tester, delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(repository.deleted, isTrue);
    expect(repository.rows, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final locale in ['en', 'it', 'es']) {
    testWidgets(
      '$locale add and notes dialogs fit small screens with keyboard and large text',
      (tester) async {
        final repository = MemoryRepository();
        await open(
          tester,
          repository,
          locale: locale,
          scale: 1.8,
          keyboard: 200,
        );
        final quickAdd = find.widgetWithIcon(
          TextButton,
          Icons.add_circle_outline,
        );
        await reach(tester, quickAdd);
        await tester.tap(quickAdd);
        await tester.pumpAndSettle();
        await reach(
          tester,
          find.byKey(const ValueKey('max-test-private-notes')),
        );
        expect(tester.takeException(), isNull);
        final l10n = AppLocalizations.of(
          tester.element(find.byType(AlertDialog)),
        )!;
        await tester.tap(find.widgetWithText(TextButton, l10n.trainerCancel));
        await tester.pumpAndSettle();
        final notes = find.byKey(const ValueKey('max-series-notes-existing'));
        await reach(tester, notes);
        await tester.tap(notes);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'custom results remain recordable when the catalog is unavailable',
    (tester) async {
      final repository = MemoryRepository();
      await open(tester, repository, catalogUnavailable: true);
      await reach(tester, find.byKey(const ValueKey('max-tests-add')));
      await tester.tap(find.byKey(const ValueKey('max-tests-add')));
      await tester.pumpAndSettle();
      await reach(tester, find.byKey(const ValueKey('max-test-exercise')));
      await tester.tap(find.byKey(const ValueKey('max-test-exercise')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();
      await reach(
        tester,
        find.byKey(const ValueKey('max-test-custom-exercise')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('max-test-custom-exercise')),
        'Assisted hold',
      );
      await reach(tester, find.byKey(const ValueKey('max-test-value')));
      await tester.enterText(
        find.byKey(const ValueKey('max-test-value')),
        '25',
      );
      await tester.tap(find.byKey(const ValueKey('max-test-save')));
      await tester.pumpAndSettle();
      expect(repository.added?['exercise_id'], isNull);
      expect(repository.added?['exercise'], 'Assisted hold');
      expect(tester.takeException(), isNull);
    },
  );
}
