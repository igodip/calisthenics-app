import 'package:calisync/trainer/components/trainer_trainee_card.dart';
import 'package:calisync/trainer/pages/trainer_dashboard_page.dart';
import 'package:calisync/trainer/pages/trainer_feedback_page.dart';
import 'package:calisync/trainer/pages/trainer_payments_page.dart';
import 'package:calisync/trainer/pages/trainer_program_page.dart';
import 'package:calisync/trainer/trainer_models.dart';
import 'package:calisync/trainer/trainer_repository.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final trainee = TrainerTrainee(
  id: '12345678-1234-1234-1234-123456789012',
  name: 'Athlete With A Very Long Display Name',
  weight: 72.5,
  height: 1.75,
  paid: false,
  paymentAmount: 125,
  coachTip: '',
  trainerNotes: '',
  completedExercises: 17,
  totalExercises: 24,
);

final feedback = TrainerFeedback(
  id: 'feedback-1',
  traineeId: trainee.id,
  traineeName: trainee.name,
  message: 'The last workout felt challenging but manageable.',
  createdAt: DateTime(2026, 8, 14),
  readAt: null,
  answer: '',
  answeredAt: null,
);

void main() {
  Future<void> pumpAt(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  testWidgets('trainer dashboard does not overflow on a narrow phone', (
    tester,
  ) async {
    await pumpAt(
      tester,
      TrainerDashboardPage(
        trainees: [trainee],
        feedback: const [],
        onOpenTrainee: (_) {},
        onRefresh: () async {},
      ),
      const Size(320, 700),
    );
  });

  testWidgets('feedback filters wrap on a narrow phone', (tester) async {
    await pumpAt(
      tester,
      TrainerFeedbackPage(
        feedback: [feedback],
        onToggleRead: (_, _) async {},
        onAnswer: (_, _) async {},
        onDelete: (_) async {},
        onRefresh: () async {},
      ),
      const Size(320, 700),
    );
    final selectedChip = tester.widget<ChoiceChip>(
      find.byType(ChoiceChip).at(1),
    );
    expect(selectedChip.selected, isTrue);
  });

  testWidgets('payment content stays responsive on phone and tablet', (
    tester,
  ) async {
    for (final size in const [Size(320, 700), Size(1200, 900)]) {
      await pumpAt(
        tester,
        TrainerPaymentsPage(
          trainees: [trainee],
          onSave: (_, _, _) async {},
          onRefresh: () async {},
        ),
        size,
      );
      final content = tester.getSize(
        find.byKey(const ValueKey('trainer-responsive-content')),
      );
      expect(content.width, lessThanOrEqualTo(960));
    }
  });

  testWidgets('trainee calendar shows the first two weeks in day order', (
    tester,
  ) async {
    final days = [
      {'week': 2, 'day_code': 'C', 'title': 'Week 2 - Day C'},
      {'week': 1, 'day_code': 'C', 'title': 'Week 1 - Day C'},
      {'week': 2, 'day_code': 'A', 'title': 'Week 2 - Day A'},
      {'week': 3, 'day_code': 'A', 'title': 'Week 3 - Day A'},
      {'week': 1, 'day_code': 'A', 'title': 'Week 1 - Day A'},
      {'week': 2, 'day_code': 'B', 'title': 'Week 2 - Day B'},
      {'week': 1, 'day_code': 'B', 'title': 'Week 1 - Day B'},
    ];
    final repository = _FakeTrainerRepository(
      TrainerProgramData(
        plans: const [],
        days: days,
        maxTests: const [],
        weightLogs: const [],
        payments: const [],
        feedback: const [],
      ),
    );

    await pumpAt(
      tester,
      TrainerProgramPage(
        trainee: trainee,
        allTrainees: [trainee],
        repository: repository,
        onTraineeChanged: (_) {},
      ),
      const Size(800, 900),
    );
    await tester.pumpAndSettle();

    expect(find.text('Week 3 - Day A'), findsNothing);
    final dayTitles = [
      'Week 1 - Day A',
      'Week 1 - Day B',
      'Week 1 - Day C',
      'Week 2 - Day A',
      'Week 2 - Day B',
      'Week 2 - Day C',
    ];
    final positions = dayTitles
        .map((title) => tester.getTopLeft(find.text(title)).dy)
        .toList();
    expect(positions, orderedEquals(positions.toList()..sort()));
  });

  testWidgets(
    'trainee card shows initials when no profile image is available',
    (tester) async {
      await pumpAt(
        tester,
        TrainerTraineeCard(
          trainee: TrainerTrainee(
            id: 'trainee-1',
            name: 'Alice',
            weight: 60,
            height: 170,
            paid: true,
            paymentAmount: 100,
            coachTip: '',
            trainerNotes: '',
            completedExercises: 1,
            totalExercises: 2,
          ),
          onOpen: () {},
        ),
        const Size(500, 700),
      );

      expect(find.text('A'), findsOneWidget);
    },
  );

  test('trainer trainee keeps profile image URL when provided', () {
    final trainee = TrainerTrainee(
      id: 'trainee-1',
      name: 'Alice',
      weight: 60,
      height: 170,
      paid: true,
      paymentAmount: 100,
      coachTip: '',
      trainerNotes: '',
      completedExercises: 1,
      totalExercises: 2,
      profileImageUrl: 'https://example.com/avatar.png',
    );

    expect(trainee.profileImageUrl, 'https://example.com/avatar.png');
  });
}

class _FakeTrainerRepository extends Fake implements TrainerRepository {
  _FakeTrainerRepository(this.program);

  final TrainerProgramData program;

  @override
  Future<TrainerProgramData> loadProgram(
    TrainerTrainee trainee,
    List<TrainerTrainee> allTrainees,
  ) async => program;
}
