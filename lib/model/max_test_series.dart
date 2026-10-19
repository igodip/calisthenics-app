import 'exercise_guide.dart';
import 'max_test.dart';

enum MaxTestCategory { pull, push, legs, core, skills, other }

MaxTestCategory maxTestCategoryForSlug(String slug) => switch (slug) {
  'pull-up' ||
  'chin-up' ||
  'australian-row' ||
  'muscle-up' => MaxTestCategory.pull,
  'push-up' ||
  'dips' ||
  'straight-bar-dip' ||
  'pike-push-up' ||
  'bodyweight-triceps-extension' => MaxTestCategory.push,
  'bodyweight-squat' ||
  'squat' ||
  'glute-bridge' ||
  'lunge' => MaxTestCategory.legs,
  'hanging-leg-raise' ||
  'hollow-body-hold' ||
  'plank' ||
  'l-sit' => MaxTestCategory.core,
  'handstand-hold' ||
  'handstand-push-up' ||
  'planche' ||
  'front-lever' ||
  'back-lever' ||
  'human-flag' => MaxTestCategory.skills,
  _ => MaxTestCategory.other,
};

String normalizeMaxTestUnit(String raw) => switch (raw.trim().toLowerCase()) {
  'rep' || 'reps' || 'rip' || 'ripetizioni' => 'reps',
  's' || 'sec' || 'second' || 'seconds' || 'secondi' => 'seconds',
  'min' || 'minute' || 'minutes' || 'minuti' => 'minutes',
  final unit => unit,
};

/// Values with different units never share a trend or personal best. Catalog
/// UUIDs, stable slugs and known translated names resolve to the same identity.
class MaxTestSeries {
  const MaxTestSeries({
    required this.key,
    required this.name,
    required this.category,
    required this.unit,
    required this.tests,
  });

  final String key;
  final String name;
  final MaxTestCategory category;
  final String unit;

  /// Newest first, preserving server order for attempts on the same date.
  final List<MaxTest> tests;
  MaxTest get latest => tests.first;
  double get best =>
      tests.map((test) => test.value).reduce((a, b) => a > b ? a : b);
  double? get change => tests.length < 2 ? null : latest.value - tests[1].value;

  static List<MaxTestSeries> build(
    List<MaxTest> tests,
    List<ExerciseGuide> guides,
  ) {
    final byIdentity = <String, ExerciseGuide>{};
    for (final guide in guides) {
      for (final identity in [guide.databaseId, guide.id, guide.name]) {
        if (identity.trim().isNotEmpty) {
          byIdentity[identity.trim().toLowerCase()] = guide;
        }
      }
    }
    final groups = <String, List<MaxTest>>{};
    final matchedGuides = <String, ExerciseGuide?>{};
    for (final test in tests) {
      final raw = test.exercise.trim().toLowerCase();
      final guide =
          byIdentity[test.exerciseId?.toLowerCase()] ?? byIdentity[raw];
      final identity = guide?.databaseId.isNotEmpty == true
          ? guide!.databaseId
          : (test.exerciseId?.trim().isNotEmpty == true
                ? test.exerciseId!
                : raw);
      final key = '$identity|${normalizeMaxTestUnit(test.unit)}';
      groups.putIfAbsent(key, () => []).add(test);
      matchedGuides[key] = guide;
    }
    final result = <MaxTestSeries>[];
    for (final entry in groups.entries) {
      // Explicit index tie-break preserves same-day server insertion order.
      final indexed = entry.value.indexed.toList()
        ..sort((a, b) {
          final date = b.$2.recordedAt.compareTo(a.$2.recordedAt);
          return date == 0 ? a.$1.compareTo(b.$1) : date;
        });
      final sorted = indexed.map((item) => item.$2).toList();
      final guide = matchedGuides[entry.key];
      result.add(
        MaxTestSeries(
          key: entry.key,
          name: guide?.name ?? sorted.first.exercise.trim(),
          category: maxTestCategoryForSlug(
            guide?.id ?? sorted.first.exercise.trim().toLowerCase(),
          ),
          unit: normalizeMaxTestUnit(sorted.first.unit),
          tests: sorted,
        ),
      );
    }
    return result..sort((a, b) {
      final name = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return name == 0 ? a.unit.compareTo(b.unit) : name;
    });
  }
}
