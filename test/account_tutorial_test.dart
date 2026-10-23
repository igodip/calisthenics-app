import 'package:calisync/components/account_tutorial_gate.dart';
import 'package:calisync/data/account_access.dart';
import 'package:calisync/data/account_tutorial_repository.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/pages/account_tutorial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AccountAccess access({
  bool trainer = false,
  bool paid = true,
  bool active = true,
  bool admin = false,
}) => AccountAccess(
  isTrainer: trainer,
  isAdmin: admin,
  isTrainee: true,
  isPaid: paid,
  isActive: active,
  monthStart: '2026-10-01',
  name: 'Test',
);

class TutorialFixture extends Fake implements AccountTutorialRepository {
  bool completed = false, failRead = false, failSave = false;
  bool? skipped;
  int reads = 0, saves = 0;
  @override
  Future<bool> hasCompleted() async {
    reads++;
    if (failRead) throw StateError('offline');
    return completed;
  }

  @override
  Future<void> syncPending() async {}
  @override
  Future<void> complete({required bool skipped}) async {
    saves++;
    if (failSave) throw StateError('offline');
    completed = true;
    this.skipped = skipped;
  }
}

void main() {
  Future<void> gate(
    WidgetTester tester,
    TutorialFixture repository,
    AccountAccess? role,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AccountTutorialGate(
          userId: 'user',
          access: role,
          repository: repository,
          child: const Scaffold(body: Text('Account controls')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'waits for roles, skips once, and stays dismissed on rebuild/remount',
    (tester) async {
      final repository = TutorialFixture();
      await gate(tester, repository, null);
      expect(repository.reads, 0);
      await gate(tester, repository, access(paid: false));
      expect(find.byType(AccountTutorialPage), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tutorial-skip')));
      await tester.pumpAndSettle();
      expect(repository.skipped, isTrue);
      expect(find.byType(AccountTutorialPage), findsNothing);
      await gate(tester, repository, access());
      expect(repository.reads, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await gate(tester, repository, access());
      expect(find.byType(AccountTutorialPage), findsNothing);
    },
  );

  testWidgets('failed lookup permits account controls and retries on resume', (
    tester,
  ) async {
    final repository = TutorialFixture()..failRead = true;
    await gate(tester, repository, access());
    expect(find.byType(AccountTutorialPage), findsNothing);
    expect(find.text('Account controls').hitTestable(), findsOneWidget);
    repository.failRead = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(AccountTutorialPage), findsOneWidget);
  });

  testWidgets('inactive accounts do not receive the tutorial', (tester) async {
    final repository = TutorialFixture();
    await gate(tester, repository, access(active: false));
    expect(repository.reads, 0);
  });

  testWidgets('save failure keeps tutorial retryable; back navigates steps', (
    tester,
  ) async {
    final repository = TutorialFixture()..failSave = true;
    await gate(tester, repository, access());
    await tester.tap(find.byKey(const ValueKey('tutorial-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Calisync'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('tutorial-skip')));
    await tester.pumpAndSettle();
    expect(find.byType(AccountTutorialPage), findsOneWidget);
    repository.failSave = false;
    await tester.tap(find.byKey(const ValueKey('tutorial-skip')));
    await tester.pumpAndSettle();
    expect(find.byType(AccountTutorialPage), findsNothing);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    for (final role in ['trainee', 'waiting', 'trainer']) {
      testWidgets(
        '$locale $role tutorial fits large text and completes every step',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(320, 568));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          bool? skipped;
          final titles = <String>{};
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(2)),
                child: child!,
              ),
              home: AccountTutorialPage(
                access: access(
                  trainer: role == 'trainer',
                  paid: role != 'waiting',
                ),
                onComplete: (value) async {
                  skipped = value;
                },
              ),
            ),
          );
          await tester.pumpAndSettle();
          final l = AppLocalizations.of(
            tester.element(find.byType(AccountTutorialPage)),
          )!;
          for (var i = 0; i < 10 && skipped == null; i++) {
            titles.addAll(
              tester
                  .widgetList<Text>(find.byType(Text))
                  .map((text) => text.data ?? ''),
            );
            final next = find.byKey(const ValueKey('tutorial-next'));
            expect(next.hitTestable(), findsOneWidget);
            await tester.tap(next);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          expect(skipped, isFalse);
          expect(titles.contains(l.waitingForTrainerTitle), role == 'waiting');
          expect(titles.contains(l.trainerNavPayments), role == 'trainer');
        },
      );
    }
  }
}
