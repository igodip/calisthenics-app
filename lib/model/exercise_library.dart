// ignore_for_file: public_member_api_docs, sort_constructors_first
class ExerciseLibrary {
  final String? id;
  final String? owner;
  final String name;
  final dynamic type;
  final dynamic primaryMuscles;
  final dynamic secondaryMuscles;
  final dynamic equipment;
  final bool? isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const ExerciseLibrary({
    required this.name,
    this.id,
    this.owner,
    this.type,
    this.primaryMuscles,
    this.secondaryMuscles,
    this.equipment,
    this.isPublic,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ExerciseLibrary.fromMap(Map<String, dynamic> map) {
    return ExerciseLibrary(
      id: map['id'] as String?,
      owner: map['owner'] as String?,
      name: map['name'] as String,
      type: map['type'],
      primaryMuscles: map['primary_muscles'],
      secondaryMuscles: map['secondary_muscles'],
      equipment: map['equipment'],
      isPublic: map['is_public'] as bool?,
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
      'type': type,
      'primary_muscles': primaryMuscles,
      'secondary_muscles': secondaryMuscles,
      'equipment': equipment,
      'is_public': isPublic,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  ExerciseLibrary copyWith({
    String? id,
    String? owner,
    String? name,
    dynamic type,
    dynamic primaryMuscles,
    dynamic secondaryMuscles,
    dynamic equipment,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ExerciseLibrary(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      type: type ?? this.type,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() => 'ExerciseLibrary(${{
        'id': id,
        'owner': owner,
        'name': name,
        'type': type,
        'primaryMuscles': primaryMuscles,
        'secondaryMuscles': secondaryMuscles,
        'equipment': equipment,
        'isPublic': isPublic,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deletedAt': deletedAt,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseLibrary &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      owner == other.owner &&
      name == other.name &&
      type == other.type &&
      primaryMuscles == other.primaryMuscles &&
      secondaryMuscles == other.secondaryMuscles &&
      equipment == other.equipment &&
      isPublic == other.isPublic &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      deletedAt == other.deletedAt;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        owner,
        name,
        type,
        primaryMuscles,
        secondaryMuscles,
        equipment,
        isPublic,
        createdAt,
        updatedAt,
        deletedAt,
      ]);
}