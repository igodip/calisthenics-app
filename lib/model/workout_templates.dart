// ignore_for_file: public_member_api_docs, sort_constructors_first
class WorkoutTemplates {
  final String? id;
  final String owner;
  final String name;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const WorkoutTemplates({
    required this.owner,
    required this.name,
    this.id,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory WorkoutTemplates.fromMap(Map<String, dynamic> map) {
    return WorkoutTemplates(
      id: map['id'] as String?,
      owner: map['owner'] as String,
      name: map['name'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null ? (map['created_at'] is DateTime ? (map['created_at'] as DateTime) : DateTime.parse(map['created_at'].toString())) : null,
      updatedAt: map['updated_at'] != null ? (map['updated_at'] is DateTime ? (map['updated_at'] as DateTime) : DateTime.parse(map['updated_at'].toString())) : null,
      deletedAt: map['deleted_at'] != null ? (map['deleted_at'] is DateTime ? (map['deleted_at'] as DateTime) : DateTime.parse(map['deleted_at'].toString())) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'name': name,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  WorkoutTemplates copyWith({
    String? id,
    String? owner,
    String? name,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return WorkoutTemplates(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() => 'WorkoutTemplates(${{
        'id': id,
        'owner': owner,
        'name': name,
        'notes': notes,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deletedAt': deletedAt,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTemplates &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      owner == other.owner &&
      name == other.name &&
      notes == other.notes &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      deletedAt == other.deletedAt;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        owner,
        name,
        notes,
        createdAt,
        updatedAt,
        deletedAt,
      ]);
}