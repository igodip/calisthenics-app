// ignore_for_file: public_member_api_docs, sort_constructors_first
class SessionExercises {
  final String? id;
  final String sessionId;
  final String exerciseId;
  final int? position;
  final String? notes;

  const SessionExercises({
    required this.sessionId,
    required this.exerciseId,
    this.id,
    this.position,
    this.notes,
  });

  factory SessionExercises.fromMap(Map<String, dynamic> map) {
    return SessionExercises(
      id: map['id'] as String?,
      sessionId: map['session_id'] as String,
      exerciseId: map['exercise_id'] as String,
      position: (map['position'] as num?)?.toInt(),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'position': position,
      'notes': notes,
    };
  }

  SessionExercises copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    int? position,
    String? notes,
  }) {
    return SessionExercises(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'SessionExercises(${{
        'id': id,
        'sessionId': sessionId,
        'exerciseId': exerciseId,
        'position': position,
        'notes': notes,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionExercises &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      sessionId == other.sessionId &&
      exerciseId == other.exerciseId &&
      position == other.position &&
      notes == other.notes;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        sessionId,
        exerciseId,
        position,
        notes,
      ]);
}