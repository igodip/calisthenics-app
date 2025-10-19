// ignore_for_file: public_member_api_docs, sort_constructors_first
class Profiles {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? unitSystem;
  final String? timezone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Profiles({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.unitSystem,
    this.timezone,
    this.createdAt,
    this.updatedAt,
  });

  factory Profiles.fromMap(Map<String, dynamic> map) {
    return Profiles(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      unitSystem: map['unit_system'] as String?,
      timezone: map['timezone'] as String?,
      createdAt: map['created_at'] != null ? (map['created_at'] is DateTime ? (map['created_at'] as DateTime) : DateTime.parse(map['created_at'].toString())) : null,
      updatedAt: map['updated_at'] != null ? (map['updated_at'] is DateTime ? (map['updated_at'] as DateTime) : DateTime.parse(map['updated_at'].toString())) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'unit_system': unitSystem,
      'timezone': timezone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Profiles copyWith({
    String? id,
    String? fullName,
    String? avatarUrl,
    String? unitSystem,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profiles(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unitSystem: unitSystem ?? this.unitSystem,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Profiles(${{
        'id': id,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
        'unitSystem': unitSystem,
        'timezone': timezone,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profiles &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      fullName == other.fullName &&
      avatarUrl == other.avatarUrl &&
      unitSystem == other.unitSystem &&
      timezone == other.timezone &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        fullName,
        avatarUrl,
        unitSystem,
        timezone,
        createdAt,
        updatedAt,
      ]);
}