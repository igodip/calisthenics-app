import 'package:calisync/pages/home_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification routes resolve to stable typed home sections', () {
    expect(
      homeSectionForNotificationRoute('trainee_plan', isTrainer: false),
      HomeSection.workoutPlan,
    );
    expect(
      homeSectionForNotificationRoute('trainee_feedback', isTrainer: false),
      HomeSection.traineeFeedback,
    );
    expect(
      homeSectionForNotificationRoute('trainer_feedback', isTrainer: true),
      HomeSection.trainerFeedback,
    );
    expect(
      homeSectionForNotificationRoute('trainer_feedback', isTrainer: false),
      HomeSection.home,
    );
    expect(
      homeSectionForNotificationRoute('unknown', isTrainer: true),
      HomeSection.home,
    );
  });
}
