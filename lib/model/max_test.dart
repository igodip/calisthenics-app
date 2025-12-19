class MaxTest {
  final String id;
  final String exercise;
  final double value;
  final String unit;
  final DateTime recordedAt;

  const MaxTest({
    required this.id,
    required this.exercise,
    required this.value,
    required this.unit,
    required this.recordedAt,
  });

  factory MaxTest.fromMap(Map<String, dynamic> map) {
    return MaxTest(
      id: map['id'] as String,
      exercise: map['exercise'] as String? ?? '',
      value: (map['value'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? '',
      recordedAt: DateTime.tryParse(map['recorded_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise': exercise,
      'value': value,
      'unit': unit,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}
