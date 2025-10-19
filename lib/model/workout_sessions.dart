// ignore_for_file: public_member_api_docs, sort_constructors_first
class WorkoutSessions {
  final String? id;
  final String owner;
  final String? templateId;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;
  final num? perceivedIntensity;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  final String? clientVersion;

  const WorkoutSessions({
    required this.owner,
    this.id,
    this.templateId,
    this.startTime,
    this.endTime,
    this.notes,
    this.perceivedIntensity,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deviceId,
    this.clientVersion,
  });

  factory WorkoutSessions.fromMap(Map<String, dynamic> map) {
    return WorkoutSessions(
      id: map['id'] as String?,
      owner: map['owner'] as String,
      templateId: map['template_id'] as String?,
      startTime: map['start_time'] != null ? (map['start_time'] is DateTime ? (map['start_time'] as DateTime) : DateTime.parse(map['start_time'].toString())) : null,
      endTime: map['end_time'] != null ? (map['end_time'] is DateTime ? (map['end_time'] as DateTime) : DateTime.parse(map['end_time'].toString())) : null,
      notes: map['notes'] as String?,
      perceivedIntensity: map['perceived_intensity'] as num?,
      createdAt: map['created_at'] != null ? (map['created_at'] is DateTime ? (map['created_at'] as DateTime) : DateTime.parse(map['created_at'].toString())) : null,
      updatedAt: map['updated_at'] != null ? (map['updated_at'] is DateTime ? (map['updated_at'] as DateTime) : DateTime.parse(map['updated_at'].toString())) : null,
      deletedAt: map['deleted_at'] != null ? (map['deleted_at'] is DateTime ? (map['deleted_at'] as DateTime) : DateTime.parse(map['deleted_at'].toString())) : null,
      deviceId: map['device_id'] as String?,
      clientVersion: map['client_version'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'template_id': templateId,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'notes': notes,
      'perceived_intensity': perceivedIntensity,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'device_id': deviceId,
      'client_version': clientVersion,
    };
  }

  WorkoutSessions copyWith({
    String? id,
    String? owner,
    String? templateId,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    num? perceivedIntensity,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deviceId,
    String? clientVersion,
  }) {
    return WorkoutSessions(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      templateId: templateId ?? this.templateId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      perceivedIntensity: perceivedIntensity ?? this.perceivedIntensity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      clientVersion: clientVersion ?? this.clientVersion,
    );
  }

  @override
  String toString() => 'WorkoutSessions(${{
        'id': id,
        'owner': owner,
        'templateId': templateId,
        'startTime': startTime,
        'endTime': endTime,
        'notes': notes,
        'perceivedIntensity': perceivedIntensity,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deletedAt': deletedAt,
        'deviceId': deviceId,
        'clientVersion': clientVersion,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessions &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      owner == other.owner &&
      templateId == other.templateId &&
      startTime == other.startTime &&
      endTime == other.endTime &&
      notes == other.notes &&
      perceivedIntensity == other.perceivedIntensity &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      deletedAt == other.deletedAt &&
      deviceId == other.deviceId &&
      clientVersion == other.clientVersion;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        owner,
        templateId,
        startTime,
        endTime,
        notes,
        perceivedIntensity,
        createdAt,
        updatedAt,
        deletedAt,
        deviceId,
        clientVersion,
      ]);
}