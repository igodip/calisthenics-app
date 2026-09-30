import 'package:calisync/model/max_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('max test parses stable identifiers and measurement data', () {
    final test = MaxTest.fromMap({
      'id': 'test-id',
      'exercise_id': 'exercise-id',
      'exercise': 'pull-up',
      'value': 12,
      'unit': 'reps',
      'recorded_at': '2026-09-30',
    });

    expect(test.id, 'test-id');
    expect(test.exerciseId, 'exercise-id');
    expect(test.value, 12);
    expect(test.recordedAt, DateTime(2026, 9, 30));
  });

  test('max test rejects missing values instead of inventing defaults', () {
    expect(
      () => MaxTest.fromMap({
        'id': 'test-id',
        'exercise': 'pull-up',
        'value': null,
        'unit': 'reps',
        'recorded_at': null,
      }),
      throwsFormatException,
    );
  });
}
