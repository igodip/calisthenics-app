import 'package:supabase_flutter/supabase_flutter.dart';

import '../notifications/push_notification_service.dart';
import 'trainer_models.dart';
import 'pdf/trainer_pdf_import.dart';

class TrainerRepository {
  TrainerRepository([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No authenticated user');
    return id;
  }

  static String currentMonthStart() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-01';
  }

  Future<TrainerProfile?> currentTrainer() async {
    final row = await _client
        .from('trainers')
        .select('id, name')
        .eq('id', _userId)
        .maybeSingle();
    return row == null ? null : TrainerProfile.fromMap(row);
  }

  Future<List<TrainerTrainee>> loadTrainees() async {
    final rows = await _client
        .from('trainees')
        .select(
          'id, name, weight, trainee_trainers!inner(trainer_id, coach_tip, trainer_notes)',
        )
        .eq('trainee_trainers.trainer_id', _userId)
        .order('name');
    final raw = List<Map<String, dynamic>>.from(rows);
    final ids = raw.map((e) => e['id'] as String).toList();
    if (ids.isEmpty) return const [];

    final paymentRows = await _client
        .from('trainee_monthly_payments')
        .select('trainee_id, paid, amount')
        .eq('month_start', currentMonthStart())
        .inFilter('trainee_id', ids);
    final payments = {
      for (final row in List<Map<String, dynamic>>.from(paymentRows))
        row['trainee_id'] as String: row,
    };

    final exerciseRows = await _client
        .from('day_exercises')
        .select(
          'completed, days!inner(workout_plan_days!inner(workout_plans!inner(trainee_id)))',
        )
        .inFilter('days.workout_plan_days.workout_plans.trainee_id', ids);
    final progress = <String, List<int>>{};
    for (final row in List<Map<String, dynamic>>.from(exerciseRows)) {
      final days = trainerRelationRow(row['days']);
      final links = trainerRelationRows(days?['workout_plan_days']);
      if (links.isEmpty) continue;
      final plan = trainerRelationRow(links.first['workout_plans']);
      final traineeId = plan?['trainee_id'] as String?;
      if (traineeId == null) continue;
      final counts = progress.putIfAbsent(traineeId, () => [0, 0]);
      counts[1]++;
      if (row['completed'] == true) counts[0]++;
    }

    return raw.map((row) {
      final id = row['id'] as String;
      final assignments = trainerRelationRows(row['trainee_trainers']);
      final assignment = assignments.firstWhere(
        (item) => item['trainer_id'] == _userId,
        orElse: () => <String, dynamic>{},
      );
      final payment = payments[id];
      final counts = progress[id] ?? const [0, 0];
      return TrainerTrainee(
        id: id,
        name: (row['name'] as String?)?.trim().isNotEmpty == true
            ? row['name'] as String
            : id.substring(0, 8),
        weight: (row['weight'] as num?)?.toDouble(),
        paid: payment?['paid'] == true,
        paymentAmount: (payment?['amount'] as num?)?.toDouble(),
        coachTip: (assignment['coach_tip'] as String?) ?? '',
        trainerNotes: (assignment['trainer_notes'] as String?) ?? '',
        completedExercises: counts[0],
        totalExercises: counts[1],
      );
    }).toList();
  }

  Future<List<TrainerFeedback>> loadFeedback(
    List<TrainerTrainee> trainees,
  ) async {
    if (trainees.isEmpty) return const [];
    final names = {for (final trainee in trainees) trainee.id: trainee.name};
    final rows = await _client
        .from('trainee_feedbacks')
        .select(
          'id, trainee_id, message, created_at, read_at, answer_message, answered_at',
        )
        .inFilter('trainee_id', names.keys.toList())
        .order('created_at', ascending: false)
        .limit(200);
    return List<Map<String, dynamic>>.from(
      rows,
    ).map((row) => _feedbackFromMap(row, names)).toList();
  }

  TrainerFeedback _feedbackFromMap(
    Map<String, dynamic> row,
    Map<String, String> names,
  ) => TrainerFeedback(
    id: row['id']!,
    traineeId: row['trainee_id'] as String,
    traineeName:
        names[row['trainee_id']] ??
        (row['trainee_id'] as String).substring(0, 8),
    message: (row['message'] as String?) ?? '',
    createdAt: DateTime.tryParse((row['created_at'] as String?) ?? ''),
    readAt: DateTime.tryParse((row['read_at'] as String?) ?? ''),
    answer: (row['answer_message'] as String?) ?? '',
    answeredAt: DateTime.tryParse((row['answered_at'] as String?) ?? ''),
  );

  Future<void> setFeedbackRead(Object id, bool value) => _client
      .from('trainee_feedbacks')
      .update({
        'read_at': value ? DateTime.now().toUtc().toIso8601String() : null,
      })
      .eq('id', id);

  Future<void> answerFeedback(Object id, String answer) async {
    final result = await _client
        .from('trainee_feedbacks')
        .update({
          'answer_message': answer,
          'answered_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .isFilter('answered_at', null)
        .select('id');
    if ((result as List).isEmpty) {
      throw StateError('This feedback was already answered.');
    }
    await PushNotificationService.instance.notifyEvent(
      'trainer_feedback_answered',
      id,
    );
  }

  Future<void> deleteFeedback(Object id) =>
      _client.from('trainee_feedbacks').delete().eq('id', id);

  Future<void> saveCoachFields(
    String traineeId, {
    required String coachTip,
    required String trainerNotes,
  }) async {
    final current = await _client
        .from('trainee_trainers')
        .select('coach_tip')
        .eq('trainee_id', traineeId)
        .eq('trainer_id', _userId)
        .maybeSingle();
    final nextCoachTip = coachTip.trim();
    final coachTipChanged =
        ((current?['coach_tip'] as String?) ?? '').trim() != nextCoachTip;
    await _client
        .from('trainee_trainers')
        .update({
          'coach_tip': nextCoachTip.isEmpty ? null : nextCoachTip,
          'trainer_notes': trainerNotes.trim().isEmpty
              ? null
              : trainerNotes.trim(),
        })
        .eq('trainee_id', traineeId)
        .eq('trainer_id', _userId);
    if (coachTipChanged) {
      await PushNotificationService.instance.notifyEvent(
        'trainer_coach_tip_updated',
        traineeId,
      );
    }
  }

  Future<void> savePayment(
    String traineeId, {
    required bool paid,
    double? amount,
  }) async {
    await _client.from('trainee_monthly_payments').upsert({
      'trainee_id': traineeId,
      'month_start': currentMonthStart(),
      'paid': paid,
      'paid_at': paid ? DateTime.now().toUtc().toIso8601String() : null,
      'amount': amount,
    }, onConflict: 'trainee_id,month_start');
    await PushNotificationService.instance.notifyEvent(
      'trainer_payment_updated',
      traineeId,
    );
  }

  Future<TrainerProgramData> loadProgram(
    TrainerTrainee trainee,
    List<TrainerTrainee> allTrainees,
  ) async {
    final results = await Future.wait([
      _client
          .from('workout_plans')
          .select('id, title, status, starts_on, notes, created_at')
          .eq('trainee_id', trainee.id)
          .order('created_at', ascending: false),
      _client
          .from('days')
          .select(
            'id, title, week, day_code, notes, completed_at, workout_plan_days!inner(plan_id, position, workout_plans!inner(trainee_id)), day_exercises(id, exercise, duration_minutes, notes, trainee_notes, exercise_feedback, completed, completed_reps, position)',
          )
          .eq('workout_plan_days.workout_plans.trainee_id', trainee.id)
          .order('week'),
      _client
          .from('max_tests')
          .select('id, exercise, value, unit, recorded_at')
          .eq('trainee_id', trainee.id)
          .order('recorded_at', ascending: false),
      _client
          .from('trainee_weight_logs')
          .select('id, weight, recorded_at, notes')
          .eq('trainee_id', trainee.id)
          .order('recorded_at', ascending: false),
      _client
          .from('trainee_monthly_payments')
          .select('id, month_start, paid, paid_at, amount')
          .eq('trainee_id', trainee.id)
          .order('month_start', ascending: false),
    ]);
    final feedback = (await loadFeedback(
      allTrainees,
    )).where((item) => item.traineeId == trainee.id).toList();
    return TrainerProgramData(
      plans: List<Map<String, dynamic>>.from(results[0] as List),
      days: List<Map<String, dynamic>>.from(results[1] as List),
      maxTests: List<Map<String, dynamic>>.from(results[2] as List),
      weightLogs: List<Map<String, dynamic>>.from(results[3] as List),
      payments: List<Map<String, dynamic>>.from(results[4] as List),
      feedback: feedback,
    );
  }

  Future<void> addMaxTest(
    String traineeId, {
    required String exercise,
    required double value,
    required String unit,
  }) => _client.from('max_tests').insert({
    'trainee_id': traineeId,
    'exercise': exercise,
    'value': value,
    'unit': unit,
    'recorded_at': DateTime.now().toIso8601String().substring(0, 10),
  });

  Future<void> addWeight(String traineeId, double weight, String notes) =>
      _client.from('trainee_weight_logs').insert({
        'trainee_id': traineeId,
        'weight': weight,
        'recorded_at': DateTime.now().toIso8601String().substring(0, 10),
        'notes': notes.trim().isEmpty ? null : notes.trim(),
      });

  Future<void> createPlan(
    String traineeId, {
    required String title,
    required String status,
    String? startsOn,
    String? notes,
  }) async {
    final inserted = await _client
        .from('workout_plans')
        .insert({
          'trainee_id': traineeId,
          'title': title,
          'status': status,
          'starts_on': startsOn,
          'notes': notes,
        })
        .select('id')
        .single();
    await PushNotificationService.instance.notifyEvent(
      'trainer_plan_updated',
      inserted['id']!,
    );
  }

  Future<void> createImportedPlan(
    String traineeId,
    TrainerPdfPlan imported,
  ) async {
    Object? planId;
    var dayIds = <Object>[];
    try {
      final plan = await _client
          .from('workout_plans')
          .insert({
            'trainee_id': traineeId,
            'title': imported.name,
            'status': 'active',
            'starts_on': DateTime.now().toIso8601String().substring(0, 10),
            'notes': null,
          })
          .select('id')
          .single();
      planId = plan['id'];

      final dayRows = await _client
          .from('days')
          .insert([
            for (final day in imported.days)
              {
                'week': day.week,
                'day_code': day.dayCode,
                'title': day.title,
                'notes': null,
              },
          ])
          .select('id');
      dayIds = List<Map<String, dynamic>>.from(
        dayRows,
      ).map((row) => row['id'] as Object).toList();

      await _client.from('workout_plan_days').insert([
        for (var index = 0; index < dayIds.length; index++)
          {'plan_id': planId, 'day_id': dayIds[index], 'position': index + 1},
      ]);

      final catalogRows = await _client
          .from('exercises')
          .select('id, slug, name');
      final catalog = List<Map<String, dynamic>>.from(catalogRows);
      Map<String, dynamic>? resolveExercise(String name) {
        final needle = _normalizeExerciseName(name);
        for (final exercise in catalog) {
          final candidates = [
            exercise['name'],
            exercise['slug'],
          ].whereType<String>().map(_normalizeExerciseName);
          if (candidates.contains(needle)) return exercise;
        }
        return null;
      }

      final exerciseRows = <Map<String, dynamic>>[];
      for (var dayIndex = 0; dayIndex < imported.days.length; dayIndex++) {
        final day = imported.days[dayIndex];
        for (var position = 0; position < day.exercises.length; position++) {
          final importedExercise = day.exercises[position];
          final resolved = resolveExercise(importedExercise.name);
          exerciseRows.add({
            'day_id': dayIds[dayIndex],
            'position': position + 1,
            'exercise_id': resolved?['id'],
            'exercise': resolved?['name'] ?? importedExercise.name,
            'notes': importedExercise.notes,
            'completed': false,
            'duration_minutes': null,
          });
        }
      }
      if (exerciseRows.isNotEmpty) {
        await _client.from('day_exercises').insert(exerciseRows);
      }
      await PushNotificationService.instance.notifyEvent(
        'trainer_plan_updated',
        planId!,
      );
    } catch (_) {
      if (dayIds.isNotEmpty) {
        await _client.from('day_exercises').delete().inFilter('day_id', dayIds);
        await _client
            .from('workout_plan_days')
            .delete()
            .inFilter('day_id', dayIds);
        await _client.from('days').delete().inFilter('id', dayIds);
      }
      if (planId != null) {
        await _client.from('workout_plans').delete().eq('id', planId);
      }
      rethrow;
    }
  }

  static String _normalizeExerciseName(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  Future<void> deletePlan(Object id) async {
    final links = await _client
        .from('workout_plan_days')
        .select('day_id')
        .eq('plan_id', id);
    final dayIds = List<Map<String, dynamic>>.from(
      links,
    ).map((row) => row['day_id']).whereType<Object>().toList();
    if (dayIds.isNotEmpty) {
      await _client.from('day_exercises').delete().inFilter('day_id', dayIds);
      await _client.from('workout_plan_days').delete().eq('plan_id', id);
      await _client.from('days').delete().inFilter('id', dayIds);
    }
    await _client.from('workout_plans').delete().eq('id', id);
  }
}
