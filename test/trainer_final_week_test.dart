import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/trainer/components/trainer_trainee_card.dart';
import 'package:calisync/trainer/pages/trainer_dashboard_page.dart';
import 'package:calisync/trainer/trainer_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TrainerTrainee athlete(String id, {bool finalWeek = false}) => TrainerTrainee(
  id: id,
  name: 'Athlete $id',
  weight: null,
  height: null,
  paid: true,
  paymentAmount: null,
  coachTip: '',
  trainerNotes: '',
  completedExercises: 12,
  totalExercises: 15,
  isInFinalWeek: finalWeek,
);

void main() {
  test(
    'final-week state defaults off and survives profile/payment changes',
    () {
      expect(athlete('regular').isInFinalWeek, isFalse);
      expect(
        athlete(
          'final',
          finalWeek: true,
        ).copyWith(paid: false, coachTip: 'Keep going').isInFinalWeek,
        isTrue,
      );
    },
  );

  Future<void> open(
    WidgetTester tester,
    Widget child, {
    String locale = 'en',
    double scale = 1,
  }) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'dashboard prioritizes final-week athletes beyond the first six without duplicates',
    (tester) async {
      TrainerTrainee? selected;
      final finalAthlete = athlete('last', finalWeek: true);
      await open(
        tester,
        TrainerDashboardPage(
          trainees: [for (var i = 0; i < 8; i++) athlete('$i'), finalAthlete],
          feedback: const [],
          onOpenTrainee: (value) => selected = value,
          onRefresh: () async {},
        ),
      );
      expect(find.text('Trainees in their final week (1)'), findsOneWidget);
      expect(find.text('Athlete last'), findsOneWidget);
      final cards = tester
          .widgetList<TrainerTraineeCard>(find.byType(TrainerTraineeCard))
          .toList();
      expect(cards.first.trainee.id, 'last');
      expect(cards.where((card) => card.trainee.id == 'last'), hasLength(1));
      await tester.ensureVisible(find.text('Athlete last'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Athlete last'));
      expect(selected, same(finalAthlete));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'all final-week athletes remain visible even when there are more than six',
    (tester) async {
      await open(
        tester,
        TrainerDashboardPage(
          trainees: [
            for (var i = 0; i < 8; i++) athlete('$i', finalWeek: true),
          ],
          feedback: const [],
          onOpenTrainee: (_) {},
          onRefresh: () async {},
        ),
      );
      expect(find.text('Trainees in their final week (8)'), findsOneWidget);
      expect(find.byType(TrainerTraineeCard), findsNWidgets(8));
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['it', 'en', 'es']) {
    testWidgets(
      '$locale final-week highlight fits narrow screens and large text',
      (tester) async {
        await open(
          tester,
          ListView(
            children: [
              TrainerTraineeCard(
                trainee: athlete('last', finalWeek: true),
                onOpen: () {},
              ),
            ],
          ),
          locale: locale,
          scale: 2,
        );
        final cardContext = tester.element(find.byType(TrainerTraineeCard));
        expect(
          find.text(AppLocalizations.of(cardContext)!.trainerFinalWeekLabel),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('final-week-last')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('ordinary athlete has no final-week label or dashboard section', (
    tester,
  ) async {
    await open(
      tester,
      TrainerDashboardPage(
        trainees: [athlete('regular')],
        feedback: const [],
        onOpenTrainee: (_) {},
        onRefresh: () async {},
      ),
    );
    expect(find.textContaining('final week'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
