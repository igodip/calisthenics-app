class MaxTest {
  final String id;
  final String? exerciseId;
  final String exercise;
  final double value;
  final String unit;
  final DateTime recordedAt;

  const MaxTest({
    required this.id,
    required this.exerciseId,
    required this.exercise,
    required this.value,
    required this.unit,
    required this.recordedAt,
  });

  factory MaxTest.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    final value = map['value'] as num?;
    final recordedAt = DateTime.tryParse(map['recorded_at'] as String? ?? '');
    if (id == null || value == null || recordedAt == null) {
      throw const FormatException('Invalid max test record.');
    }
    return MaxTest(
      id: id,
      exerciseId: map['exercise_id'] as String?,
      exercise: map['exercise'] as String? ?? '',
      value: value.toDouble(),
      unit: map['unit'] as String? ?? '',
      recordedAt: recordedAt,
    );
  }
}
