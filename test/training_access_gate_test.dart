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
}
