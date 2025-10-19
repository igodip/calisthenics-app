// ignore_for_file: public_member_api_docs, sort_constructors_first
class MediaRefs {
  final String? id;
  final String owner;
  final String? exerciseId;
  final String url;
  final String? kind;
  final DateTime? createdAt;

  const MediaRefs({
    required this.owner,
    required this.url,
    this.id,
    this.exerciseId,
    this.kind,
    this.createdAt,
  });

  factory MediaRefs.fromMap(Map<String, dynamic> map) {
    return MediaRefs(
      id: map['id'] as String?,
      owner: map['owner'] as String,
      exerciseId: map['exercise_id'] as String?,
      url: map['url'] as String,
      kind: map['kind'] as String?,
      createdAt: map['created_at'] != null ? (map['created_at'] is DateTime ? (map['created_at'] as DateTime) : DateTime.parse(map['created_at'].toString())) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'exercise_id': exerciseId,
      'url': url,
      'kind': kind,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  MediaRefs copyWith({
    String? id,
    String? owner,
    String? exerciseId,
    String? url,
    String? kind,
    DateTime? createdAt,
  }) {
    return MediaRefs(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      exerciseId: exerciseId ?? this.exerciseId,
      url: url ?? this.url,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'MediaRefs(${{
        'id': id,
        'owner': owner,
        'exerciseId': exerciseId,
        'url': url,
        'kind': kind,
        'createdAt': createdAt,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaRefs &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      owner == other.owner &&
      exerciseId == other.exerciseId &&
      url == other.url &&
      kind == other.kind &&
      createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        owner,
        exerciseId,
        url,
        kind,
        createdAt,
      ]);
}