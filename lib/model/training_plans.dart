// ignore_for_file: public_member_api_docs, sort_constructors_first
class TrainingPlans {
  final String? id;
  final String owner;
  final String name;
  final String? goal;
  final int? weeks;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const TrainingPlans({
    required this.owner,
    required this.name,
    this.id,
    this.goal,
    this.weeks,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory TrainingPlans.fromMap(Map<String, dynamic> map) {
    return TrainingPlans(
      id: map['id'] as String?,
      owner: map['owner'] as String,
      name: map['name'] as String,
      goal: map['goal'] as String?,
      weeks: (map['weeks'] as num?)?.toInt(),
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
      'goal': goal,
      'weeks': weeks,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  TrainingPlans copyWith({
    String? id,
    String? owner,
    String? name,
    String? goal,
    int? weeks,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TrainingPlans(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      weeks: weeks ?? this.weeks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() => 'TrainingPlans(${{
        'id': id,
        'owner': owner,
        'name': name,
        'goal': goal,
        'weeks': weeks,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deletedAt': deletedAt,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingPlans &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      owner == other.owner &&
      name == other.name &&
      goal == other.goal &&
      weeks == other.weeks &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      deletedAt == other.deletedAt;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        owner,
        name,
        goal,
        weeks,
        createdAt,
        updatedAt,
        deletedAt,
      ]);
}