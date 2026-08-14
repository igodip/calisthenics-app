import 'package:calisync/trainer/trainer_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('trainerRelationRows accepts a to-one PostgREST object', () {
    final rows = trainerRelationRows({'trainer_id': 'trainer-1'});

    expect(rows, hasLength(1));
    expect(rows.single['trainer_id'], 'trainer-1');
  });

  test('trainerRelationRows accepts a to-many PostgREST list', () {
    final rows = trainerRelationRows([
      {'trainer_id': 'trainer-1'},
      {'trainer_id': 'trainer-2'},
    ]);

    expect(rows, hasLength(2));
    expect(rows.last['trainer_id'], 'trainer-2');
  });

  test('trainerRelationRows safely handles null', () {
    expect(trainerRelationRows(null), isEmpty);
    expect(trainerRelationRow(null), isNull);
  });

  test('removing a plan also removes its linked workout days', () {
    final data = TrainerProgramData(
      plans: [
        {'id': 'plan-a'},
        {'id': 'plan-b'},
      ],
      days: [
        {
          'id': 'day-a',
          'workout_plan_days': {'plan_id': 'plan-a'},
        },
        {
          'id': 'day-b',
          'workout_plan_days': [
            {'plan_id': 'plan-b'},
          ],
        },
      ],
      maxTests: const [],
      weightLogs: const [],
      payments: const [],
      feedback: const [],
    );

    final updated = data.withoutPlan('plan-a');

    expect(updated.plans.map((plan) => plan['id']), ['plan-b']);
    expect(updated.days.map((day) => day['id']), ['day-b']);
  });

  test('removing feedback keeps the rest of the program data', () {
    final first = TrainerFeedback(
      id: 'feedback-a',
      traineeId: 'trainee-a',
      traineeName: 'Ada',
      message: 'First',
      createdAt: null,
      readAt: null,
      answer: '',
      answeredAt: null,
    );
    final second = TrainerFeedback(
      id: 'feedback-b',
      traineeId: 'trainee-a',
      traineeName: 'Ada',
      message: 'Second',
      createdAt: null,
      readAt: null,
      answer: '',
      answeredAt: null,
    );
    final data = TrainerProgramData(
      plans: const [],
      days: const [],
      maxTests: const [],
      weightLogs: const [],
      payments: const [],
      feedback: [first, second],
    );

    final updated = data.withoutFeedback(first.id);

    expect(updated.feedback.map((item) => item.id), ['feedback-b']);
  });
}
