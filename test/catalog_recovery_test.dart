import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/model/exercise_guide.dart';
import 'package:calisync/model/terminology_entry.dart';
import 'package:calisync/pages/exercise_guides_page.dart';
import 'package:calisync/pages/terminology_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final guides in [true, false]) {
    final catalog = guides ? 'guides' : 'terminology';
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets(
        '$catalog retries offline startup and refreshes updates in $locale',
        (tester) async {
          var online = false;
          var revision = 1;
          Future<List<ExerciseGuide>> loadGuides(String _) async {
            if (!online) throw StateError('offline');
            return [
              ExerciseGuide(
                databaseId: 'id',
                id: 'custom-guide',
                name: 'Guide $revision',
                difficulty: Difficulty.advanced,
                focus: 'Focus',
                tip: 'Tip',
                description: 'Description',
              ),
            ];
          }

          Future<List<TerminologyEntry>> loadTerms(String _) async {
            if (!online) throw StateError('offline');
            return [
              TerminologyEntry(
                termKey: 'target',
                term: 'Term $revision',
                description: 'Description',
                sortOrder: 0,
              ),
            ];
          }

          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: guides
                    ? ExerciseGuidesPage(
                        initialGuideSlug: 'custom-guide',
                        loadGuides: loadGuides,
                      )
                    : TerminologyPage(termKey: 'target', loadTerms: loadTerms),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(FilledButton), findsOneWidget);
          online = true;
          await tester.ensureVisible(find.byType(FilledButton));
          await tester.tap(find.byType(FilledButton));
          await tester.pumpAndSettle();
          expect(find.text('${guides ? 'Guide' : 'Term'} 1'), findsOneWidget);
          revision = 2;
          final refresh = find.byType(IconButton).first;
          await tester.ensureVisible(refresh);
          await tester.tap(refresh);
          await tester.pumpAndSettle();
          expect(find.text('${guides ? 'Guide' : 'Term'} 2'), findsOneWidget);
          revision = 3;
          // Pull-to-refresh also works for a list shorter than its viewport.
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, 500),
          );
          await tester.pumpAndSettle();
          expect(find.text('${guides ? 'Guide' : 'Term'} 3'), findsOneWidget);
          revision = 4;
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pumpAndSettle();
          expect(find.text('${guides ? 'Guide' : 'Term'} 4'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
