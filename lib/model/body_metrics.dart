// ignore_for_file: public_member_api_docs, sort_constructors_first
class BodyMetrics {
  final String? id;
  final String owner;
  final DateTime? measuredAt;
  final num? weight;
  final num? bodyFatPct;
  final num? chest;
  final num? waist;
  final num? hips;
  final String? notes;

  const BodyMetrics({
    required this.owner,
    this.id,
    this.measuredAt,
    this.weight,
    this.bodyFatPct,
    this.chest,
    this.waist,
    this.hips,
    this.notes,
  });

  factory BodyMetrics.fromMap(Map<String, dynamic> map) {
    return BodyMetrics(
      id: map['id'] as String?,
      owner: map['owner'] as String,
      measuredAt: map['measured_at'] != null ? (map['measured_at'] is DateTime ? (map['measured_at'] as DateTime) : DateTime.parse(map['measured_at'].toString())) : null,
      weight: map['weight'] as num?,
      bodyFatPct: map['body_fat_pct'] as num?,
      chest: map['chest'] as num?,
      waist: map['waist'] as num?,
      hips: map['hips'] as num?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'measured_at': measuredAt?.toIso8601String(),
      'weight': weight,
      'body_fat_pct': bodyFatPct,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'notes': notes,
    };
  }

  BodyMetrics copyWith({
    String? id,
    String? owner,
    DateTime? measuredAt,
    num? weight,
    num? bodyFatPct,
    num? chest,
    num? waist,
    num? hips,
    String? notes,
  }) {
    return BodyMetrics(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      measuredAt: measuredAt ?? this.measuredAt,
      weight: weight ?? this.weight,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'BodyMetrics(${{
        'id': id,
        'owner': owner,
        'measuredAt': measuredAt,
        'weight': weight,
        'bodyFatPct': bodyFatPct,
        'chest': chest,
        'waist': waist,
        'hips': hips,
        'notes': notes,
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyMetrics &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      owner == other.owner &&
      measuredAt == other.measuredAt &&
      weight == other.weight &&
      bodyFatPct == other.bodyFatPct &&
      chest == other.chest &&
      waist == other.waist &&
      hips == other.hips &&
      notes == other.notes;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        owner,
        measuredAt,
        weight,
        bodyFatPct,
        chest,
        waist,
        hips,
        notes,
      ]);
}