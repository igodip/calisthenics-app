// ignore_for_file: public_member_api_docs, sort_constructors_first
class Trainee {
  final String id;
  final String? name;
  final bool? paid;

  const Trainee({
    required this.id,
    this.name,
    this.paid
  });

  factory Trainee.fromMap(Map<String, dynamic> map) {
    return Trainee(
      id: map['id'] as String,
      name: map['name'] as String?,
      paid: map['paid'] as bool?
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'paid': paid
    };
  }

  Trainee copyWith({
    String? id,
    String? name,
    bool? paid
  }) {
    return Trainee(
      id: id ?? this.id,
      name: name ?? this.name,
      paid: paid ?? this.paid
    );
  }

  @override
  String toString() => 'Profiles(${{
        'id': id,
        'name': name,
        'paid': paid
      }})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trainee &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      paid == other.paid;

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        name,
        paid
      ]);
}