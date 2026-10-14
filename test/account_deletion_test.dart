import 'package:calisync/components/account_deletion_section.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(WidgetTester tester, Future<void> Function() delete) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AccountDeletionSection(deleteAccount: delete)),
      ),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete account'));
    await tester.pumpAndSettle();
  }

  testWidgets('cancelling never deletes the account', (tester) async {
    var calls = 0;
    await open(tester, () async {
      calls++;
    });
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('failed deletion preserves the screen and permits retry', (
    tester,
  ) async {
    var calls = 0;
    await open(tester, () async {
      calls++;
      throw StateError('failure');
    });
    await tester.tap(find.widgetWithText(FilledButton, 'Delete account'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(
      find.textContaining('Could not complete account deletion'),
      findsOneWidget,
    );
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );
  });
}
