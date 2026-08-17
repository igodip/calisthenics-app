import 'dart:convert';
import 'dart:io';

import 'package:calisync/trainer/pdf/trainer_pdf_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses workout PDF tables and expands week columns', () {
    const pageA = '''
GIORNO A
Esercizi    Note    Sett 1    Sett 2    Rec/Som
Pull up    Strict form    4x5    5x5    2 min
Dips    Controlled eccentric    3x8    4x8    90 sec
''';
    const pageB = '''
GIORNO B
Esercizi    Note    Sett 1    Sett 2    Rec/Som
Squat    Full depth    4x6    5x6    2 min
''';

    final plan = const TrainerPdfImportService().parsePages(const [
      pageA,
      pageB,
    ], 'Summer strength');

    expect(plan.name, 'Summer strength');
    expect(plan.days, hasLength(4));
    expect(plan.exerciseCount, 6);
    expect(plan.days.first.week, 1);
    expect(plan.days.first.dayCode, 'A');
    expect(plan.days.first.exercises.first.name, 'Pull up');
    expect(plan.days.first.exercises.first.notes, contains('Sett 1: 4x5'));
    expect(plan.days.last.week, 2);
    expect(plan.days.last.dayCode, 'B');
  });

  test('rejects PDFs without workout day tables', () {
    expect(
      () => const TrainerPdfImportService().parsePages(const [
        'An unrelated document',
      ], 'Document'),
      throwsFormatException,
    );
  });

  test('does not mistake text-only programming values for exercises', () {
    const page = '''
GIORNO A
Esercizi    Note    Sett 1    Rec/Som
Pull up
RT
TOT
NO elastico
Dips    Controllate    3x8    90 sec
''';

    final plan = const TrainerPdfImportService().parsePages(const [
      page,
    ], 'Programming labels');

    final exerciseNames = plan.days
        .expand((day) => day.exercises)
        .map((exercise) => exercise.name)
        .toSet();
    expect(exerciseNames, containsAll(['Pull up', 'Dips']));
    expect(exerciseNames, isNot(contains('TOT')));
    expect(exerciseNames, isNot(contains('NO elastico')));
  });

  test('keeps exercises whose programming boxes are empty', () {
    const page = '''
GIORNO A
Esercizi    Note    Sett 1    Sett 2    Rec/Som
Pull up
Dips    Controlled    3x8    4x8    90 sec
''';

    final plan = const TrainerPdfImportService().parsePages(const [
      page,
    ], 'Empty programming');

    expect(plan.days, hasLength(2));
    for (final day in plan.days) {
      expect(
        day.exercises.map((exercise) => exercise.name),
        containsAll(['Pull up', 'Dips']),
      );
      final pullUp = day.exercises.singleWhere(
        (exercise) => exercise.name == 'Pull up',
      );
      expect(pullUp.notes, isNot(contains('Sett ${day.week}:')));
    }
  });

  test('keeps positioned exercise rows whose week cells are all empty', () {
    const page = TrainerPdfPositionedPage(
      width: 500,
      height: 400,
      items: [
        TrainerPdfTextItem(text: 'GIORNO A', x: 20, y: 20, width: 80),
        TrainerPdfTextItem(text: 'ESERCIZI', x: 20, y: 60, width: 80),
        TrainerPdfTextItem(text: 'Sett 1', x: 180, y: 60, width: 45),
        TrainerPdfTextItem(text: 'Sett 2', x: 280, y: 60, width: 45),
        TrainerPdfTextItem(text: 'NOTE', x: 400, y: 60, width: 40),
        TrainerPdfTextItem(text: 'Plank', x: 20, y: 110, width: 50),
        TrainerPdfTextItem(text: 'Squat', x: 20, y: 165, width: 50),
        TrainerPdfTextItem(text: '3x8', x: 180, y: 165, width: 30),
        TrainerPdfTextItem(text: '4x8', x: 280, y: 165, width: 30),
      ],
    );

    final plan = const TrainerPdfImportService().parsePositionedPages(const [
      page,
    ], 'Empty positioned programming');

    expect(plan.days, hasLength(2));
    for (final day in plan.days) {
      expect(
        day.exercises.map((exercise) => exercise.name),
        containsAll(['Plank', 'Squat']),
      );
    }
  });

  test('matches the supplied Igor 6.7-6.8 PDF fixture', () {
    expect(
      File('test/fixtures/pdf_import/igor_6_7_6_8.pdf').existsSync(),
      isTrue,
    );
    final fixture =
        jsonDecode(
              File(
                'test/fixtures/pdf_import/igor_6_7_6_8.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final expected = fixture['expected'] as Map<String, dynamic>;
    final exerciseNames = Map<String, dynamic>.from(
      expected['exerciseNames'] as Map,
    );
    final samples = List<Map<String, dynamic>>.from(
      expected['samples'] as List,
    );
    const headerXs = [51.0, 191.7, 322.0, 410.0, 491.0, 576.0, 666.0, 737.0];
    const headerWidths = [56.0, 36.0, 37.0, 37.0, 37.0, 37.0, 42.0, 58.0];
    const headers = [
      'ESERCIZI',
      'NOTE',
      'Sett 1',
      'Sett 2',
      'Sett 3',
      'Sett 4',
      'Scarico',
      'Rec/Som',
    ];
    final pages = <TrainerPdfPositionedPage>[];

    for (final dayEntry in exerciseNames.entries) {
      final day = dayEntry.key;
      final names = List<String>.from(dayEntry.value as List);
      final items = <TrainerPdfTextItem>[
        TrainerPdfTextItem(text: 'GIORNO $day', x: 210, y: 98, width: 100),
        for (var index = 0; index < headers.length; index++)
          TrainerPdfTextItem(
            text: headers[index],
            x: headerXs[index],
            y: 138,
            width: headerWidths[index],
          ),
      ];
      for (var slot = 0; slot < names.length; slot++) {
        final name = names[slot];
        final y = 175.0 + slot * 55;
        items.add(TrainerPdfTextItem(text: name, x: 45, y: y, width: 75));
        final sample = samples.cast<Map<String, dynamic>?>().firstWhere(
          (candidate) =>
              candidate?['day'] == day && candidate?['exercise'] == name,
          orElse: () => null,
        );
        if (sample != null) {
          final programming = List<String>.from(sample['programming'] as List);
          for (var week = 0; week < programming.length; week++) {
            if (programming[week].isEmpty) continue;
            items.add(
              TrainerPdfTextItem(
                text: programming[week],
                x: headerXs[week + 2],
                y: y,
                width: 65,
              ),
            );
          }
        }
        if (day == 'C' && name == 'Pull up + 1/2 rom basso') {
          items.addAll([
            TrainerPdfTextItem(text: 'Se', x: 133, y: y, width: 10),
            TrainerPdfTextItem(text: 'chiuso', x: 145, y: y, width: 28),
          ]);
        } else if (day == 'C' && name == 'Dip') {
          items.addAll([
            TrainerPdfTextItem(text: "12',", x: 133, y: y, width: 15),
            TrainerPdfTextItem(text: 'volta dopo', x: 151, y: y, width: 55),
          ]);
        } else if (day == 'C' && name == 'Body row ISO') {
          items.addAll([
            TrainerPdfTextItem(text: '6', x: 135, y: y, width: 6),
            TrainerPdfTextItem(text: 'serie totali', x: 144, y: y, width: 58),
          ]);
        }
      }
      pages.add(
        TrainerPdfPositionedPage(width: 841.92, height: 595.32, items: items),
      );
    }

    final plan = const TrainerPdfImportService().parsePositionedPages(
      pages,
      'Igor 6.7-6.8',
    );

    expect(plan.exerciseCount, expected['scheduledExerciseCount']);
    expect(
      plan.days.map((day) => day.dayCode).toSet(),
      Set<String>.from(expected['dayCodes'] as List),
    );
    for (final dayEntry in exerciseNames.entries) {
      for (var week = 1; week <= 5; week++) {
        final day = plan.days.singleWhere(
          (candidate) =>
              candidate.dayCode == dayEntry.key && candidate.week == week,
        );
        expect(
          day.exercises.map((exercise) => exercise.name).toList(),
          List<String>.from(dayEntry.value as List),
        );
      }
    }
    final boundaryCases = Map<String, dynamic>.from(
      expected['boundaryCases'] as Map,
    );
    final dayC = plan.days.singleWhere(
      (day) => day.dayCode == 'C' && day.week == 1,
    );
    for (final boundaryCase in boundaryCases.entries) {
      expect(
        dayC.exercises
            .singleWhere((exercise) => exercise.name == boundaryCase.key)
            .notes,
        contains(boundaryCase.value),
      );
    }
  });

  test('matches the imported website Bux layout fixture', () {
    final fixture =
        jsonDecode(
              File(
                'test/fixtures/pdf_import/bux_app_layout.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final expected = fixture['expected'] as Map<String, dynamic>;
    final slotCounts = Map<String, dynamic>.from(expected['slotCounts'] as Map);
    final samples = List<Map<String, dynamic>>.from(
      expected['samples'] as List,
    );
    final sparseSlots = {'A:1', 'A:5', 'B:5', 'C:0', 'C:4', 'D:4'};
    const columns = [20.0, 260.0, 360.0, 460.0, 560.0, 660.0, 760.0];
    final pages = <TrainerPdfPositionedPage>[];

    for (final entry in slotCounts.entries) {
      final day = entry.key;
      final count = entry.value as int;
      final items = <TrainerPdfTextItem>[
        const TrainerPdfTextItem(text: 'GIORNO A', x: 20, y: 20, width: 80),
      ];
      items[0] = TrainerPdfTextItem(
        text: 'GIORNO $day',
        x: 20,
        y: 20,
        width: 80,
      );
      const headers = [
        'ESERCIZI',
        'Sett 1',
        'Sett 2',
        'Sett 3',
        'Sett 4',
        'Sett 5',
        'NOTE',
      ];
      for (var index = 0; index < headers.length; index++) {
        final weekHeader = RegExp(r'^Sett ([1-5])$').firstMatch(headers[index]);
        if (weekHeader == null) {
          items.add(
            TrainerPdfTextItem(
              text: headers[index],
              x: columns[index],
              y: 60,
              width: index == 0 ? 80 : 48,
            ),
          );
        } else {
          items.addAll([
            TrainerPdfTextItem(
              text: 'Sett',
              x: columns[index],
              y: 60,
              width: 22,
            ),
            TrainerPdfTextItem(
              text: weekHeader.group(1)!,
              x: columns[index] + 26,
              y: 60,
              width: 7,
            ),
          ]);
        }
      }

      for (var slot = 0; slot < count; slot++) {
        final sample = samples.cast<Map<String, dynamic>?>().firstWhere(
          (candidate) =>
              candidate?['day'] == day &&
              ((day == 'A' &&
                      slot == 0 &&
                      candidate?['exercise'] == 'HSPU liberi') ||
                  (day == 'A' &&
                      slot == 1 &&
                      candidate?['exercise'] == 'RDL') ||
                  (day == 'B' &&
                      slot == 0 &&
                      candidate?['exercise'] == 'Pull up al petto') ||
                  (day == 'C' &&
                      slot == 0 &&
                      candidate?['exercise'] == 'HSPU tenute') ||
                  (day == 'D' &&
                      slot == 0 &&
                      candidate?['exercise'] == 'Military')),
          orElse: () => null,
        );
        final exercise = sample?['exercise'] as String? ?? 'Exercise $day$slot';
        final programming = sample == null
            ? [
                '3x${slot + 3}',
                if (!sparseSlots.contains('$day:$slot')) ...[
                  '4x${slot + 3}',
                  '5x${slot + 3}',
                  '4x${slot + 4}',
                  '5x${slot + 4}',
                ] else ...[
                  '',
                  '',
                  '',
                  '',
                ],
              ]
            : List<String>.from(sample['programming'] as List);
        final y = 105.0 + slot * 55;
        if (exercise == 'Pull up al petto') {
          items.addAll([
            TrainerPdfTextItem(text: 'Pull up', x: columns[0], y: y, width: 55),
            TrainerPdfTextItem(
              text: 'al petto',
              x: columns[0],
              y: y + 12,
              width: 60,
            ),
          ]);
        } else {
          items.add(
            TrainerPdfTextItem(text: exercise, x: columns[0], y: y, width: 150),
          );
        }
        for (var week = 0; week < programming.length; week++) {
          if (programming[week].isEmpty) continue;
          items.add(
            TrainerPdfTextItem(
              text: programming[week],
              x: columns[week + 1],
              y: y,
              width: 72,
            ),
          );
        }
        final notes = sample?['notes'] as String?;
        if (notes != null) {
          items.add(
            TrainerPdfTextItem(text: notes, x: columns.last, y: y, width: 75),
          );
        }
      }
      pages.add(
        TrainerPdfPositionedPage(width: 841.92, height: 595.32, items: items),
      );
    }

    final plan = const TrainerPdfImportService().parsePositionedPages(
      pages,
      'Bux fixture',
    );

    expect(
      plan.days.map((day) => day.dayCode).toSet(),
      Set<String>.from(expected['dayCodes'] as List),
    );
    expect(plan.exerciseCount, expected['scheduledExerciseCount']);
    for (final entry in slotCounts.entries) {
      final names = plan.days
          .where((day) => day.dayCode == entry.key)
          .expand((day) => day.exercises)
          .map((exercise) => exercise.name)
          .toSet();
      expect(names, hasLength(entry.value as int));
    }
    for (final sample in samples) {
      final programming = List<String>.from(sample['programming'] as List);
      for (var week = 0; week < programming.length; week++) {
        if (programming[week].isEmpty) continue;
        final day = plan.days.singleWhere(
          (item) => item.dayCode == sample['day'] && item.week == week + 1,
        );
        final exercise = day.exercises.singleWhere(
          (item) => item.name == sample['exercise'],
        );
        expect(
          exercise.notes,
          contains('Sett ${week + 1}: ${programming[week]}'),
        );
        if (sample['notes'] != null) {
          expect(exercise.notes, contains(sample['notes']));
        }
      }
    }
  });
}
