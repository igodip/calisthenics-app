import 'package:calisync/model/max_test.dart';
import 'package:calisync/model/trainee.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Trainee parses nullable profile fields', () {
    final trainee = Trainee.fromMap({
      'id': 'trainee-1',
      'name': 'Alex',
      'weight': 72,
      'height': 180.5,
      'profile_image_url': null,
    });

    expect(trainee.id, 'trainee-1');
    expect(trainee.name, 'Alex');
    expect(trainee.weight, 72);
    expect(trainee.height, 180.5);
    expect(trainee.profileImageUrl, isNull);
  });

  test('MaxTest parses database values', () {
    final test = MaxTest.fromMap({
      'exercise': 'Pull-up',
      'value': 15,
      'unit': 'reps',
      'recorded_at': '2026-08-08T10:00:00.000Z',
    });

    expect(test.exercise, 'Pull-up');
    expect(test.value, 15);
    expect(test.unit, 'reps');
    expect(test.recordedAt, DateTime.utc(2026, 8, 8, 10));
  });
}
