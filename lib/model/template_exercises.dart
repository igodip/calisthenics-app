// ignore_for_file: public_member_api_docs, sort_constructors_first
class TemplateExercises {
  final String? id;
  final String templateId;
  final String exerciseId;
  final int? position;
  final dynamic defaultIntensity;
  final int? defaultSets;
  final int? defaultReps;
  final num? defaultWeight;
  final num? defaultRpe;
  final int? restSeconds;

  const TemplateExercises({
    required this.templateId,
    required this.exerciseId,
    this.id,
    this.position,
    this.defaultIntensity,
    this.defaultSets,
    this.defaultReps,
    this.defaultWeight,
    this.defaultRpe,
    this.restSeconds,
  });

  factory TemplateExercises.fromMap(Map<String, dynamic> map) {
    return TemplateExercises(
      id: map['id'] as String?,
      templateId: map['template_id'] as String,
      exerciseId: map['exercise_id'] as String,
      position: (map['position'] as num?)?.toInt(),
      defaultIntensity: map['default_intensity'],
      defaultSets: (map['default_sets'] as num?)?.toInt(),
      defaultReps: (map['default_reps'] as num?)?.toInt(),
      defaultWeight: map['default_weight'] as num?,
      defaultRpe: map['default_rpe'] as num?,
      restSeconds: (map['rest_seconds'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template_id': templateId,
      'exercise_id': exerciseId,
      'position': position,
      'default_intensity': defaultIntensity,
      'default_sets': defaultSets,
      'default_reps': defaultReps,
      'default_weight': defaultWeight,
      'default_rpe': defaultRpe,
      'rest_seconds': restSeconds,
    };
  }

  TemplateExercises copyWith({
    String? id,
    String? templateId,
    String? exerciseId,
    int? position,
    dynamic defaultIntensity,
    int? defaultSets,
    int? defaultReps,
    num? defaultWeight,
    num? defaultRpe,
    int? restSeconds,
  }) {
    return TemplateExercises(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      defaultIntensity: defaultIntensity ?? this.defaultIntensity,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      defaultRpe: defaultRpe ?? this.defaultRpe,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  @override
  String toString() => 'TemplateExercises(${{
        'id': id,
        'templateId': templateId,
        'exerciseId': exerciseId,
        'position': position,
        'defaultIntensity': defaultIntensity,
        'defaultSets': defaultSets,
        'defaultReps': defaultReps,
        'defaultWeight': defaultWeight,
        'defaultRpe': defaultRpe,
        'restSeconds': restSeconds,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateExercises &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      templateId == other.templateId &&
      exerciseId == other.exerciseId &&
      position == other.position &&
      defaultIntensity == other.defaultIntensity &&
      defaultSets == other.defaultSets &&
      defaultReps == other.defaultReps &&
      defaultWeight == other.defaultWeight &&
      defaultRpe == other.defaultRpe &&
      restSeconds == other.restSeconds;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        templateId,
        exerciseId,
        position,
        defaultIntensity,
        defaultSets,
        defaultReps,
        defaultWeight,
        defaultRpe,
        restSeconds,
      ]);
}