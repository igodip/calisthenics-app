// ignore_for_file: public_member_api_docs, sort_constructors_first
class PlanWorkouts {
  final String? id;
  final String planId;
  final int week;
  final int dow;
  final String templateId;
  final int? position;

  const PlanWorkouts({
    required this.planId,
    required this.week,
    required this.dow,
    required this.templateId,
    this.id,
    this.position,
  });

  factory PlanWorkouts.fromMap(Map<String, dynamic> map) {
    return PlanWorkouts(
      id: map['id'] as String?,
      planId: map['plan_id'] as String,
      week: (map['week'] as num).toInt(),
      dow: (map['dow'] as num).toInt(),
      templateId: map['template_id'] as String,
      position: (map['position'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_id': planId,
      'week': week,
      'dow': dow,
      'template_id': templateId,
      'position': position,
    };
  }

  PlanWorkouts copyWith({
    String? id,
    String? planId,
    int? week,
    int? dow,
    String? templateId,
    int? position,
  }) {
    return PlanWorkouts(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      week: week ?? this.week,
      dow: dow ?? this.dow,
      templateId: templateId ?? this.templateId,
      position: position ?? this.position,
    );
  }

  @override
  String toString() => 'PlanWorkouts(${{
        'id': id,
        'planId': planId,
        'week': week,
        'dow': dow,
        'templateId': templateId,
        'position': position,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanWorkouts &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      planId == other.planId &&
      week == other.week &&
      dow == other.dow &&
      templateId == other.templateId &&
      position == other.position;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        planId,
        week,
        dow,
        templateId,
        position,
      ]);
}