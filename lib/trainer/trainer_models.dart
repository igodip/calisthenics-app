List<Map<String, dynamic>> trainerRelationRows(Object? value) {
  if (value is Map<String, dynamic>) return [value];
  if (value is Map) return [Map<String, dynamic>.from(value)];
  if (value is List) {
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
  return const [];
}

Map<String, dynamic>? trainerRelationRow(Object? value) {
  final rows = trainerRelationRows(value);
  return rows.isEmpty ? null : rows.first;
}

class TrainerProfile {
  const TrainerProfile({required this.id, required this.name});

  final String id;
  final String name;

  factory TrainerProfile.fromMap(Map<String, dynamic> map) => TrainerProfile(
    id: map['id'] as String,
    name: (map['name'] as String?)?.trim().isNotEmpty == true
        ? map['name'] as String
        : 'Trainer',
  );
}

class TrainerTrainee {
  const TrainerTrainee({
    required this.id,
    required this.name,
    required this.weight,
    required this.paid,
    required this.paymentAmount,
    required this.coachTip,
    required this.trainerNotes,
    required this.completedExercises,
    required this.totalExercises,
  });

  final String id;
  final String name;
  final double? weight;
  final bool paid;
  final double? paymentAmount;
  final String coachTip;
  final String trainerNotes;
  final int completedExercises;
  final int totalExercises;

  int get progress => totalExercises == 0
      ? 0
      : ((completedExercises / totalExercises) * 100).round();

  TrainerTrainee copyWith({
    bool? paid,
    double? paymentAmount,
    String? coachTip,
    String? trainerNotes,
  }) => TrainerTrainee(
    id: id,
    name: name,
    weight: weight,
    paid: paid ?? this.paid,
    paymentAmount: paymentAmount ?? this.paymentAmount,
    coachTip: coachTip ?? this.coachTip,
    trainerNotes: trainerNotes ?? this.trainerNotes,
    completedExercises: completedExercises,
    totalExercises: totalExercises,
  );
}

class TrainerFeedback {
  const TrainerFeedback({
    required this.id,
    required this.traineeId,
    required this.traineeName,
    required this.message,
    required this.createdAt,
    required this.readAt,
    required this.answer,
    required this.answeredAt,
  });

  final Object id;
  final String traineeId;
  final String traineeName;
  final String message;
  final DateTime? createdAt;
  final DateTime? readAt;
  final String answer;
  final DateTime? answeredAt;

  bool get isRead => readAt != null;
  bool get isAnswered => answeredAt != null;

  TrainerFeedback copyWith({
    DateTime? readAt,
    bool clearReadAt = false,
    String? answer,
    DateTime? answeredAt,
  }) => TrainerFeedback(
    id: id,
    traineeId: traineeId,
    traineeName: traineeName,
    message: message,
    createdAt: createdAt,
    readAt: clearReadAt ? null : readAt ?? this.readAt,
    answer: answer ?? this.answer,
    answeredAt: answeredAt ?? this.answeredAt,
  );
}

class TrainerProgramData {
  const TrainerProgramData({
    required this.plans,
    required this.days,
    required this.maxTests,
    required this.weightLogs,
    required this.payments,
    required this.feedback,
  });

  final List<Map<String, dynamic>> plans;
  final List<Map<String, dynamic>> days;
  final List<Map<String, dynamic>> maxTests;
  final List<Map<String, dynamic>> weightLogs;
  final List<Map<String, dynamic>> payments;
  final List<TrainerFeedback> feedback;

  TrainerProgramData withoutPlan(Object planId) {
    final id = '$planId';
    return TrainerProgramData(
      plans: plans.where((plan) => '${plan['id']}' != id).toList(),
      days: days.where((day) {
        final links = trainerRelationRows(day['workout_plan_days']);
        return !links.any((link) => '${link['plan_id']}' == id);
      }).toList(),
      maxTests: maxTests,
      weightLogs: weightLogs,
      payments: payments,
      feedback: feedback,
    );
  }

  TrainerProgramData withoutFeedback(Object feedbackId) => TrainerProgramData(
    plans: plans,
    days: days,
    maxTests: maxTests,
    weightLogs: weightLogs,
    payments: payments,
    feedback: feedback.where((item) => item.id != feedbackId).toList(),
  );
}
