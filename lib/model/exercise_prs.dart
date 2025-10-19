// ignore_for_file: public_member_api_docs, sort_constructors_first
class ExercisePrs {
  final String? id;
  final String owner;
  final String exerciseId;
  final int reps;
  final num? bestWeight;
  final num? estimated1rm;
  final DateTime? achievedAt;

  const ExercisePrs({
    required this.owner,
    required this.exerciseId,
    required this.reps,
    this.id,
    this.bestWeight,
    this.estimated1rm,
    this.achievedAt,
  });

  factory ExercisePrs.fromMap(Map<String, dynamic> map) {
    return ExercisePrs(
      id: map['id'] as String?,
      owner: map['owner'] as String,
      exerciseId: map['exercise_id'] as String,
      reps: (map['reps'] as num).toInt(),
      bestWeight: map['best_weight'] as num?,
      estimated1rm: map['estimated_1rm'] as num?,
      achievedAt: map['achieved_at'] != null ? (map['achieved_at'] is DateTime ? (map['achieved_at'] as DateTime) : DateTime.parse(map['achieved_at'].toString())) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'exercise_id': exerciseId,
      'reps': reps,
      'best_weight': bestWeight,
      'estimated_1rm': estimated1rm,
      'achieved_at': achievedAt?.toIso8601String(),
    };
  }

  ExercisePrs copyWith({
    String? id,
    String? owner,
    String? exerciseId,
    int? reps,
    num? bestWeight,
    num? estimated1rm,
    DateTime? achievedAt,
  }) {
    return ExercisePrs(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      exerciseId: exerciseId ?? this.exerciseId,
      reps: reps ?? this.reps,
      bestWeight: bestWeight ?? this.bestWeight,
      estimated1rm: estimated1rm ?? this.estimated1rm,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  String toString() => 'ExercisePrs(${{
        'id': id,
        'owner': owner,
        'exerciseId': exerciseId,
        'reps': reps,
        'bestWeight': bestWeight,
        'estimated1rm': estimated1rm,
        'achievedAt': achievedAt,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExercisePrs &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      owner == other.owner &&
      exerciseId == other.exerciseId &&
      reps == other.reps &&
      bestWeight == other.bestWeight &&
      estimated1rm == other.estimated1rm &&
      achievedAt == other.achievedAt;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        owner,
        exerciseId,
        reps,
        bestWeight,
        estimated1rm,
        achievedAt,
      ]);
}