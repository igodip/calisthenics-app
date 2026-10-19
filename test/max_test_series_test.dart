import 'package:calisync/model/exercise_guide.dart';
import 'package:calisync/model/max_test.dart';
import 'package:calisync/model/max_test_series.dart';
import 'package:flutter_test/flutter_test.dart';

const guide = ExerciseGuide(
  databaseId: 'catalog-pull',
  id: 'pull-up',
  name: 'Trazioni',
  difficulty: Difficulty.intermediate,
  focus: '',
  tip: '',
  description: '',
);

MaxTest attempt(
  String id,
  double value, {
  String exercise = 'pull-up',
  String? exerciseId,
  String unit = 'reps',
  int day = 1,
}) => MaxTest(
  id: id,
  exerciseId: exerciseId,
  exercise: exercise,
  value: value,
  unit: unit,
  recordedAt: DateTime(2026, 10, day),
);

void main() {
  test('UUID, slug and translated catalog names resolve to one exercise', () {
    final series = MaxTestSeries.build(
      [
        attempt('1', 10, exerciseId: 'catalog-pull', exercise: 'old name'),
        attempt('2', 11),
        attempt('3', 12, exercise: 'Trazioni'),
      ],
      [guide],
    );
    expect(series, hasLength(1));
    expect(series.single.name, 'Trazioni');
    expect(series.single.category, MaxTestCategory.pull);
    expect(series.single.tests, hasLength(3));
  });

  test(
    'keeps all attempts, including regressions, and preserves same-day order',
    () {
      final group = MaxTestSeries.build(
        [
          attempt('latest', 8, day: 3),
          attempt('same-day-earlier', 9, day: 3),
          attempt('best', 15, day: 2),
          attempt('first', 10, day: 1),
        ],
        [guide],
      ).single;
      expect(group.tests.map((test) => test.id), [
        'latest',
        'same-day-earlier',
        'best',
        'first',
      ]);
      expect(group.latest.value, 8);
      expect(group.best, 15);
      expect(group.change, -1);
    },
  );

  test('units are separated but explicit aliases are normalized', () {
    final groups = MaxTestSeries.build(
      [
        attempt('1', 10),
        attempt('2', 11, unit: 'ripetizioni'),
        attempt('3', 20, unit: 'kg'),
        attempt('4', 30, unit: 's'),
        attempt('5', 35, unit: 'seconds'),
        attempt('6', 1, unit: 'minutes'),
      ],
      [guide],
    );
    expect(groups, hasLength(4));
    expect(
      groups.singleWhere((group) => group.unit == 'reps').tests,
      hasLength(2),
    );
    expect(
      groups.singleWhere((group) => group.unit == 'seconds').tests,
      hasLength(2),
    );
  });

  test('custom movements are retained without guessing a category', () {
    final group = MaxTestSeries.build(
      [attempt('1', 3, exercise: 'Custom assisted hold')],
      [guide],
    ).single;
    expect(group.name, 'Custom assisted hold');
    expect(group.category, MaxTestCategory.other);
    expect(group.change, isNull);
  });

  test('known movement categories are stable across translations', () {
    expect(maxTestCategoryForSlug('dips'), MaxTestCategory.push);
    expect(maxTestCategoryForSlug('bodyweight-squat'), MaxTestCategory.legs);
    expect(maxTestCategoryForSlug('plank'), MaxTestCategory.core);
    expect(maxTestCategoryForSlug('handstand-hold'), MaxTestCategory.skills);
    expect(MaxTestSeries.build([], [guide]), isEmpty);
  });

  test('non-finite measurement data cannot reach progress charts', () {
    expect(
      () => MaxTest.fromMap({
        'id': 'bad',
        'value': double.infinity,
        'recorded_at': '2026-10-20',
      }),
      throwsFormatException,
    );
  });
}
