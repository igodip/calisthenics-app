class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.isTrainee,
    required this.isTrainer,
    required this.isAdmin,
    required this.isSuspended,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final bool isTrainee;
  final bool isTrainer;
  final bool isAdmin;
  final bool isSuspended;
  final DateTime? createdAt;

  factory AdminUser.fromMap(Map<String, dynamic> map) => AdminUser(
    id: map['user_id'] as String,
    email: (map['email'] as String?) ?? '',
    name: (map['name'] as String?) ?? 'User',
    isTrainee: map['is_trainee'] == true,
    isTrainer: map['is_trainer'] == true,
    isAdmin: map['is_admin'] == true,
    isSuspended: map['is_suspended'] == true,
    createdAt: DateTime.tryParse((map['created_at'] as String?) ?? ''),
  );

  AdminUser copyWith({bool? isTrainer, bool? isSuspended}) => AdminUser(
    id: id,
    email: email,
    name: name,
    isTrainee: isTrainee,
    isTrainer: isTrainer ?? this.isTrainer,
    isAdmin: isAdmin,
    isSuspended: isSuspended ?? this.isSuspended,
    createdAt: createdAt,
  );
}

class AdminAssignment {
  const AdminAssignment({
    required this.traineeId,
    required this.traineeName,
    required this.trainerId,
    required this.trainerName,
  });

  final String traineeId;
  final String traineeName;
  final String trainerId;
  final String trainerName;

  factory AdminAssignment.fromMap(Map<String, dynamic> map) => AdminAssignment(
    traineeId: map['trainee_id'] as String,
    traineeName: (map['trainee_name'] as String?) ?? 'Trainee',
    trainerId: map['trainer_id'] as String,
    trainerName: (map['trainer_name'] as String?) ?? 'Trainer',
  );
}
