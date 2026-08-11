class Trainee {
  final String id;
  final String? name;
  final double? weight;
  final double? height;
  final String? profileImageUrl;

  const Trainee({
    required this.id,
    this.name,
    this.weight,
    this.height,
    this.profileImageUrl,
  });

  factory Trainee.fromMap(Map<String, dynamic> map) {
    return Trainee(
      id: map['id'] as String,
      name: map['name'] as String?,
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      profileImageUrl: map['profile_image_url'] as String?,
    );
  }

  Trainee copyWith({
    String? id,
    String? name,
    double? weight,
    double? height,
    String? profileImageUrl,
  }) {
    return Trainee(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
