import 'dart:async';

import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/model/terminology_entry.dart';
import 'package:calisync/pages/terminology_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final terms = List.generate(
    40,
    (index) => TerminologyEntry(
      termKey: 'term-$index',
      term: 'Term $index',
      description: List.filled(
        index % 5 + 1,
        'A variable-length explanation of this training term.',
      ).join(' '),
      sortOrder: index,
    ),
  );
  Future<List<TerminologyEntry>> load(String _) async => terms;

  Future<void> show(
    WidgetTester tester,
    String? target, {
    Locale locale = const Locale('en'),
    Future<List<TerminologyEntry>> Function(String)? loader,
  }) async {
    await tester.binding.setSurfaceSize(const Size(360, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TerminologyPage(
            key: const ValueKey('glossary'),
            termKey: target,
            loadTerms: loader ?? load,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  void expectVisible(WidgetTester tester, int index) {
    final rect = tester.getRect(find.text('Term $index'));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(600));
  }

  testWidgets('initial deep link scrolls to a far off-screen term', (
    tester,
  ) async {
    await show(tester, 'term-35');
    expectVisible(tester, 35);
  });

  testWidgets(
    'already open glossary scrolls to a new target in either direction',
    (tester) async {
      await show(tester, null);
      final state = tester.state(find.byType(TerminologyPage));
      await show(tester, '  TERM-35  ');
      expect(
        identical(state, tester.state(find.byType(TerminologyPage))),
        isTrue,
      );
      expectVisible(tester, 35);
      await show(tester, 'term-1');
      expectVisible(tester, 1);
      await show(tester, 'term-39');
      expectVisible(tester, 39);
    },
  );

  testWidgets('locale reload keeps the requested term visible', (tester) async {
    await show(tester, 'term-30');
    await show(tester, 'term-30', locale: const Locale('it'));
    expectVisible(tester, 30);
  });

  testWidgets('target changed during loading scrolls to the latest request', (
    tester,
  ) async {
    final pending = Completer<List<TerminologyEntry>>();
    Future<List<TerminologyEntry>> delayed(String _) => pending.future;
    // Do not settle while the loading indicator is animating.
    Future<void> pumpTarget(String target) => tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TerminologyPage(
            key: const ValueKey('glossary'),
            termKey: target,
            loadTerms: delayed,
          ),
        ),
      ),
    );
    await pumpTarget('term-1');
    await pumpTarget('term-35');
    pending.complete(terms);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final viewport = tester.getSize(find.byType(CustomScrollView));
    expect(
      tester.getRect(find.text('Term 35')).bottom,
      lessThanOrEqualTo(viewport.height),
    );
    expect(tester.getRect(find.text('Term 35')).top, greaterThanOrEqualTo(0));
  });

  testWidgets('unknown target permits subsequent valid requests', (
    tester,
  ) async {
    await show(tester, 'missing-term');
    await show(tester, 'term-35');
    expectVisible(tester, 35);
  });
}
