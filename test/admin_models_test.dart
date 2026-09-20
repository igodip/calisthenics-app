import 'package:calisync/admin/admin_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AdminUser parses roles and access state', () {
    final user = AdminUser.fromMap({
      'user_id': 'user-1',
      'email': 'trainer@example.com',
      'name': 'Trainer One',
      'is_trainee': true,
      'is_trainer': true,
      'is_admin': false,
      'is_suspended': true,
      'created_at': '2026-09-20T12:00:00Z',
    });

    expect(user.id, 'user-1');
    expect(user.email, 'trainer@example.com');
    expect(user.isTrainee, isTrue);
    expect(user.isTrainer, isTrue);
    expect(user.isAdmin, isFalse);
    expect(user.isSuspended, isTrue);
    expect(user.createdAt, DateTime.utc(2026, 9, 20, 12));
  });

  test('AdminAssignment parses both sides', () {
    final assignment = AdminAssignment.fromMap({
      'trainee_id': 'trainee-1',
      'trainee_name': 'Trainee One',
      'trainer_id': 'trainer-1',
      'trainer_name': 'Trainer One',
    });

    expect(assignment.traineeName, 'Trainee One');
    expect(assignment.trainerName, 'Trainer One');
  });
}
