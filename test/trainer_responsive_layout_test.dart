import 'package:calisync/trainer/pages/trainer_dashboard_page.dart';
import 'package:calisync/trainer/pages/trainer_feedback_page.dart';
import 'package:calisync/trainer/pages/trainer_payments_page.dart';
import 'package:calisync/trainer/trainer_models.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const trainee = TrainerTrainee(
  id: '12345678-1234-1234-1234-123456789012',
  name: 'Athlete With A Very Long Display Name',
  weight: 72.5,
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
        trainees: const [trainee],
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
          trainees: const [trainee],
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
}
