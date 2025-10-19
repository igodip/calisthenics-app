// ignore_for_file: public_member_api_docs, sort_constructors_first
class SetLogs {
  final String? id;
  final String sessionExerciseId;
  final int setNumber;
  final dynamic intensity;
  final num? weight;
  final int? reps;
  final int? seconds;
  final num? distanceM;
  final num? rpe;
  final num? rir;
  final bool? isWarmup;
  final DateTime? createdAt;

  const SetLogs({
    required this.sessionExerciseId,
    required this.setNumber,
    this.id,
    this.intensity,
    this.weight,
    this.reps,
    this.seconds,
    this.distanceM,
    this.rpe,
    this.rir,
    this.isWarmup,
    this.createdAt,
  });

  factory SetLogs.fromMap(Map<String, dynamic> map) {
    return SetLogs(
      id: map['id'] as String?,
      sessionExerciseId: map['session_exercise_id'] as String,
      setNumber: (map['set_number'] as num).toInt(),
      intensity: map['intensity'],
      weight: map['weight'] as num?,
      reps: (map['reps'] as num?)?.toInt(),
      seconds: (map['seconds'] as num?)?.toInt(),
      distanceM: map['distance_m'] as num?,
      rpe: map['rpe'] as num?,
      rir: map['rir'] as num?,
      isWarmup: map['is_warmup'] as bool?,
      createdAt: map['created_at'] != null ? (map['created_at'] is DateTime ? (map['created_at'] as DateTime) : DateTime.parse(map['created_at'].toString())) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_exercise_id': sessionExerciseId,
      'set_number': setNumber,
      'intensity': intensity,
      'weight': weight,
      'reps': reps,
      'seconds': seconds,
      'distance_m': distanceM,
      'rpe': rpe,
      'rir': rir,
      'is_warmup': isWarmup,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  SetLogs copyWith({
    String? id,
    String? sessionExerciseId,
    int? setNumber,
    dynamic intensity,
    num? weight,
    int? reps,
    int? seconds,
    num? distanceM,
    num? rpe,
    num? rir,
    bool? isWarmup,
    DateTime? createdAt,
  }) {
    return SetLogs(
      id: id ?? this.id,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      setNumber: setNumber ?? this.setNumber,
      intensity: intensity ?? this.intensity,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      seconds: seconds ?? this.seconds,
      distanceM: distanceM ?? this.distanceM,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      isWarmup: isWarmup ?? this.isWarmup,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'SetLogs(${{
        'id': id,
        'sessionExerciseId': sessionExerciseId,
        'setNumber': setNumber,
        'intensity': intensity,
        'weight': weight,
        'reps': reps,
        'seconds': seconds,
        'distanceM': distanceM,
        'rpe': rpe,
        'rir': rir,
        'isWarmup': isWarmup,
        'createdAt': createdAt,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetLogs &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      sessionExerciseId == other.sessionExerciseId &&
      setNumber == other.setNumber &&
      intensity == other.intensity &&
      weight == other.weight &&
      reps == other.reps &&
      seconds == other.seconds &&
      distanceM == other.distanceM &&
      rpe == other.rpe &&
      rir == other.rir &&
      isWarmup == other.isWarmup &&
      createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        sessionExerciseId,
        setNumber,
        intensity,
        weight,
        reps,
        seconds,
        distanceM,
        rpe,
        rir,
        isWarmup,
        createdAt,
      ]);
}