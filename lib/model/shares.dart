// ignore_for_file: public_member_api_docs, sort_constructors_first
class Shares {
  final String? id;
  final String owner;
  final String targetUser;
  final dynamic role;
  final DateTime? createdAt;

  const Shares({
    required this.owner,
    required this.targetUser,
    this.id,
    this.role,
    this.createdAt,
  });

  factory Shares.fromMap(Map<String, dynamic> map) {
    return Shares(
      id: map['id'] as String?,
      owner: map['owner'] as String,
      targetUser: map['target_user'] as String,
      role: map['role'],
      createdAt: map['created_at'] != null ? (map['created_at'] is DateTime ? (map['created_at'] as DateTime) : DateTime.parse(map['created_at'].toString())) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'target_user': targetUser,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Shares copyWith({
    String? id,
    String? owner,
    String? targetUser,
    dynamic role,
    DateTime? createdAt,
  }) {
    return Shares(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      targetUser: targetUser ?? this.targetUser,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Shares(${{
        'id': id,
        'owner': owner,
        'targetUser': targetUser,
        'role': role,
        'createdAt': createdAt,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shares &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      owner == other.owner &&
      targetUser == other.targetUser &&
      role == other.role &&
      createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        owner,
        targetUser,
        role,
        createdAt,
      ]);
}