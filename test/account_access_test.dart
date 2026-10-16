import 'package:calisync/data/account_access.dart';
import 'package:calisync/trainer/trainer_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AccountAccess access({
    bool trainer = false,
    bool admin = false,
    bool paid = false,
    bool active = true,
  }) => AccountAccess.fromMap({
    'is_trainer': trainer,
    'is_admin': admin,
    'is_trainee': true,
    'is_paid': paid,
    'is_active': active,
    'month_start': '2026-10-01',
  });
  test(
    'only current paid trainees or privileged roles have training access',
    () {
      expect(access().hasTrainingAccess, isFalse);
      expect(access(paid: true).hasTrainingAccess, isTrue);
      expect(access(trainer: true).hasTrainingAccess, isTrue);
      expect(access(admin: true).hasTrainingAccess, isTrue);
      expect(access(paid: true, active: false).hasTrainingAccess, isFalse);
      expect(
        access(trainer: true, admin: true, active: false).hasTrainingAccess,
        isFalse,
      );
    },
  );
  test(
    'payment amount can be explicitly cleared without losing other fields',
    () {
      final trainee = TrainerTrainee(
        id: 'test',
        name: 'Test',
        weight: null,
        height: null,
        paid: true,
        paymentAmount: 50,
        paymentNotes: 'Cash',
        coachTip: '',
        trainerNotes: '',
        completedExercises: 0,
        totalExercises: 0,
      );
      expect(trainee.copyWith(paid: false).paymentAmount, 50);
      final cleared = trainee.copyWith(clearPaymentAmount: true);
      expect(cleared.paymentAmount, isNull);
      expect(cleared.paymentNotes, 'Cash');
    },
  );
}
