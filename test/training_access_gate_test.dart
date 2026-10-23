import 'dart:async';

import 'package:calisync/components/plan_expired_gate.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpGate(
    WidgetTester tester,
    Future<bool> Function() load, {
    bool bypass = false,
    VoidCallback? profile,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(title: const Text('Navigation')),
          drawer: const Drawer(child: Text('Account navigation')),
          body: PlanExpiredGate(
            loadAccess: load,
            bypass: bypass,
            onOpenProfile: profile,
            child: const Text('Training content'),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('unpaid trainees retain navigation and account controls', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    var profileOpened = false;
    await pumpGate(
      tester,
      () async => false,
      profile: () => profileOpened = true,
    );
    expect(find.text('Waiting for your trainer'), findsOneWidget);
    expect(find.text('Training content'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    expect(profileOpened, isTrue);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Account navigation'), findsOneWidget);
  });

  testWidgets('training stays closed while loading and on errors', (
    tester,
  ) async {
    final pending = Completer<bool>();
    await pumpGate(tester, () => pending.future);
    expect(find.text('Training content'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
    pending.completeError(StateError('network unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Could not check training access'), findsOneWidget);
    expect(find.text('Training content'), findsNothing);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('refresh unlocks training after activation', (tester) async {
    var allowed = false;
    await pumpGate(tester, () async => allowed);
    expect(find.text('Waiting for your trainer'), findsOneWidget);
    allowed = true;
    await tester.tap(find.text('Check again'));
    await tester.pumpAndSettle();
    expect(find.text('Training content'), findsOneWidget);
    expect(find.text('Waiting for your trainer'), findsNothing);
  });

  testWidgets('trainer bypass does not query trainee payment', (tester) async {
    var queries = 0;
    await pumpGate(tester, () async {
      queries++;
      return false;
    }, bypass: true);
    expect(queries, 0);
    expect(find.text('Training content'), findsOneWidget);
  });

  testWidgets('access is rechecked while screen stays open', (tester) async {
    var allowed = true;
    await pumpGate(tester, () async => allowed);
    expect(find.text('Training content'), findsOneWidget);
    allowed = false;
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(find.text('Training content'), findsNothing);
    expect(find.text('Waiting for your trainer'), findsOneWidget);
  });

  testWidgets('idle timer failure is handled and remains retryable', (
    tester,
  ) async {
    var offline = false;
    await pumpGate(tester, () async {
      if (offline) throw StateError('DNS lookup failed');
      return true;
    });
    offline = true;
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Could not check training access'), findsOneWidget);
    expect(find.text('Waiting for your trainer'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
    offline = false;
    await tester.tap(find.text('Check again'));
    await tester.pumpAndSettle();
    expect(find.text('Training content'), findsOneWidget);
  });

  testWidgets('background stops polling and offline resume does not throw', (
    tester,
  ) async {
    var queries = 0;
    var offline = false;
    await pumpGate(tester, () async {
      queries++;
      if (offline) throw StateError('offline');
      return true;
    });
    expect(queries, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(minutes: 2));
    expect(queries, 1);
    offline = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(queries, 2);
    expect(find.text('Could not check training access'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stalled access refresh times out without overlapping requests', (
    tester,
  ) async {
    var queries = 0;
    final pending = Completer<bool>();
    await pumpGate(tester, () {
      queries++;
      return queries == 1 ? Future.value(false) : pending.future;
    });
    await tester.tap(find.text('Check again'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 20));
    await tester.pumpAndSettle();
    expect(queries, 2);
    expect(find.text('Could not check training access'), findsOneWidget);
    expect(tester.takeException(), isNull);
    pending.completeError(StateError('late offline error'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('request failure after disposal is still observed', (
    tester,
  ) async {
    final pending = Completer<bool>();
    await pumpGate(tester, () => pending.future);
    await tester.pumpWidget(const SizedBox.shrink());
    pending.completeError(StateError('offline after leaving page'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
