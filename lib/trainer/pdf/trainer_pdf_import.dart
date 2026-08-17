import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdfrx/pdfrx.dart';

class TrainerPdfExercise {
  const TrainerPdfExercise({required this.name, required this.notes});

  final String name;
  final String notes;
}

class TrainerPdfDay {
  const TrainerPdfDay({
    required this.week,
    required this.dayCode,
    required this.title,
    required this.exercises,
  });

  final int week;
  final String dayCode;
  final String title;
  final List<TrainerPdfExercise> exercises;
}

class TrainerPdfPlan {
  const TrainerPdfPlan({required this.name, required this.days});

  final String name;
  final List<TrainerPdfDay> days;

  int get exerciseCount =>
      days.fold(0, (total, day) => total + day.exercises.length);
}

class TrainerPdfTextItem {
  const TrainerPdfTextItem({
    required this.text,
    required this.x,
    required this.y,
    required this.width,
  });

  final String text;
  final double x;
  final double y;
  final double width;

  double get centerX => x + width / 2;
}

class TrainerPdfPositionedPage {
  const TrainerPdfPositionedPage({
    required this.width,
    required this.height,
    required this.items,
  });

  final double width;
  final double height;
  final List<TrainerPdfTextItem> items;
}

class TrainerPdfImportService {
  const TrainerPdfImportService();

  Future<TrainerPdfPlan> read(String path, String fileName) async {
    await pdfrxFlutterInitialize();
    final document = await PdfDocument.openFile(path);
    return _readDocument(document, fileName);
  }

  Future<TrainerPdfPlan> readBytes(Uint8List bytes, String fileName) async {
    await pdfrxFlutterInitialize();
    final document = await PdfDocument.openData(bytes, sourceName: fileName);
    return _readDocument(document, fileName);
  }

  Future<TrainerPdfPlan> _readDocument(
    PdfDocument document,
    String fileName,
  ) async {
    try {
      final pages = <TrainerPdfPositionedPage>[];
      for (final page in document.pages) {
        final pageText = await page.loadStructuredText();
        pages.add(
          TrainerPdfPositionedPage(
            width: page.width,
            height: page.height,
            items: _positionedItems(pageText, page.height),
          ),
        );
      }
      return parsePositionedPages(
        pages,
        fileName.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), ''),
      );
    } finally {
      await document.dispose();
    }
  }

  TrainerPdfPlan parsePages(List<String> pages, String planName) {
    final parsedPages = pages.map(_parsePage).whereType<_ParsedPage>().toList()
      ..sort((a, b) => a.dayCode.compareTo(b.dayCode));
    return _buildPlan(parsedPages, planName);
  }

  TrainerPdfPlan parsePositionedPages(
    List<TrainerPdfPositionedPage> pages,
    String planName,
  ) {
    final parsedPages =
        pages.map(_parsePositionedPage).whereType<_ParsedPage>().toList()
          ..sort((a, b) => a.dayCode.compareTo(b.dayCode));
    return _buildPlan(parsedPages, planName);
  }

  TrainerPdfPlan _buildPlan(List<_ParsedPage> parsedPages, String planName) {
    if (parsedPages.isEmpty) {
      throw const FormatException('No workout tables found in the PDF.');
    }

    final weekLabels = parsedPages
        .expand((page) => page.weekLabels)
        .toSet()
        .toList();
    weekLabels.sort((a, b) => _weekOrder(a).compareTo(_weekOrder(b)));
    final effectiveWeeks = weekLabels.isEmpty ? const ['Sett 1'] : weekLabels;
    final days = <TrainerPdfDay>[];

    for (var weekIndex = 0; weekIndex < effectiveWeeks.length; weekIndex++) {
      final weekLabel = effectiveWeeks[weekIndex];
      for (final page in parsedPages) {
        final exercises = <TrainerPdfExercise>[];
        for (final row in page.rows) {
          final programming =
              row.programming[weekLabel] ??
              (effectiveWeeks.length == 1 ? row.fallbackProgramming : '');
          final notes = <String>[
            'PDF exercise: ${row.exercise}',
            if (row.notes.isNotEmpty) row.notes,
            if (programming.isNotEmpty) '$weekLabel: $programming',
            if (row.recovery.isNotEmpty) 'Rec/Som: ${row.recovery}',
          ].join('\n\n');
          exercises.add(TrainerPdfExercise(name: row.exercise, notes: notes));
        }
        if (exercises.isNotEmpty) {
          days.add(
            TrainerPdfDay(
              week: weekIndex + 1,
              dayCode: page.dayCode,
              title: 'GIORNO ${page.dayCode}',
              exercises: exercises,
            ),
          );
        }
      }
    }

    if (days.isEmpty) {
      throw const FormatException('No programmed exercises found in the PDF.');
    }
    return TrainerPdfPlan(name: planName.trim(), days: days);
  }

  static List<TrainerPdfTextItem> _positionedItems(
    PdfPageText pageText,
    double pageHeight,
  ) {
    final items = <TrainerPdfTextItem>[];
    for (final fragment in pageText.fragments) {
      for (final match in RegExp(r'\S+').allMatches(fragment.text)) {
        final rects = <PdfRect>[];
        final end = math.min(match.end, fragment.charRects.length);
        for (var index = match.start; index < end; index++) {
          final rect = fragment.charRects[index];
          if (rect.isNotEmpty) rects.add(rect);
        }
        final bounds = rects.isEmpty
            ? fragment.bounds
            : rects.skip(1).fold(rects.first, (value, rect) {
                return value.merge(rect);
              });
        final text = _normalize(match.group(0)!);
        if (text.isEmpty || bounds.isEmpty) continue;
        items.add(
          TrainerPdfTextItem(
            text: text,
            x: bounds.left,
            y: pageHeight - bounds.top,
            width: bounds.width,
          ),
        );
      }
    }
    return items;
  }

  _ParsedPage? _parsePositionedPage(TrainerPdfPositionedPage page) {
    final items = page.items
        .map(
          (item) => TrainerPdfTextItem(
            text: _normalize(item.text),
            x: item.x,
            y: item.y,
            width: item.width,
          ),
        )
        .where((item) => item.text.isNotEmpty)
        .toList();
    final rows = _positionedRows(items);
    final dayRow = rows.where(
      (row) =>
          RegExp(r'giorno\s+[a-g]', caseSensitive: false).hasMatch(row.text),
    );
    if (dayRow.isEmpty) return null;
    final dayMatch = RegExp(
      r'giorno\s+([a-g])',
      caseSensitive: false,
    ).firstMatch(dayRow.first.text)!;
    final dayCode = dayMatch.group(1)!.toUpperCase();
    final headerRows = rows.where((row) {
      final text = row.text;
      return RegExp(r'esercizi', caseSensitive: false).hasMatch(text) &&
          RegExp(r'sett|note|scarico', caseSensitive: false).hasMatch(text);
    });
    if (headerRows.isEmpty) {
      return _parsePage(rows.map((row) => row.text).join('\n'));
    }
    final header = headerRows.first;
    final columns = _headerColumns(header.items);
    if (!columns.any((column) => column.label == 'exercise') ||
        !columns.any((column) => column.label.startsWith('Sett '))) {
      return _parsePage(rows.map((row) => row.text).join('\n'));
    }

    final boundaries = _columnBoundaries(columns, page.width);
    int columnIndex(TrainerPdfTextItem item) {
      for (var index = 0; index < columns.length; index++) {
        if (item.centerX >= boundaries[index] &&
            item.centerX < boundaries[index + 1]) {
          return index;
        }
      }
      return -1;
    }

    final weekLabels = columns
        .map((column) => column.label)
        .where((label) => label.startsWith('Sett ') || label == 'Scarico')
        .toList();
    final exerciseColumn = columns.indexWhere(
      (column) => column.label == 'exercise',
    );
    final tableItems = items.where((item) => item.y > header.y + 3).toList();
    final exerciseLines = _positionedRows(
      tableItems.where((item) => columnIndex(item) == exerciseColumn).toList(),
    ).where((row) => !_isIgnored(row.text)).toList();
    if (exerciseLines.isEmpty) {
      return _parsePage(rows.map((row) => row.text).join('\n'));
    }

    final groups = <_ExerciseGroup>[];
    for (final line in exerciseLines) {
      final previous = groups.isEmpty ? null : groups.last;
      if (previous != null && line.y - previous.maxY <= 24) {
        previous.lines.add(line);
        previous.maxY = line.y;
      } else {
        groups.add(_ExerciseGroup(lines: [line], minY: line.y, maxY: line.y));
      }
    }

    final parsedRows = <_ParsedRow>[];
    for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) {
      final group = groups[groupIndex];
      final previous = groupIndex == 0 ? null : groups[groupIndex - 1];
      final next = groupIndex + 1 == groups.length
          ? null
          : groups[groupIndex + 1];
      final top = previous == null
          ? header.y + 3
          : (previous.maxY + group.minY) / 2;
      final bottom = next == null ? page.height : (group.maxY + next.minY) / 2;
      final bandItems = tableItems
          .where((item) => item.y >= top && item.y < bottom)
          .toList();
      if (bandItems.isEmpty || bandItems.any((item) => _isIgnored(item.text))) {
        continue;
      }

      final exerciseLines = <String>[];
      final noteLines = <String>[];
      final programming = <String, String>{};
      for (final row in _positionedRows(bandItems)) {
        final values = <String, List<String>>{};
        for (final item in row.items) {
          final index = columnIndex(item);
          if (index < 0) continue;
          values.putIfAbsent(columns[index].label, () => []).add(item.text);
        }
        String value(String label) =>
            _normalize((values[label] ?? const <String>[]).join(' '));
        final exercise = value('exercise');
        final notes = value('notes');
        if (exercise.isNotEmpty) exerciseLines.add(exercise);
        if (notes.isNotEmpty) noteLines.add(notes);
        for (final label in [...weekLabels, 'Rec/Som']) {
          final nextValue = value(label);
          if (nextValue.isEmpty) continue;
          programming[label] = _normalize(
            [
              programming[label] ?? '',
              nextValue,
            ].where((entry) => entry.isNotEmpty).join(' '),
          );
        }
      }
      final exercise = _normalize(exerciseLines.join(' '));
      if (exercise.isEmpty ||
          RegExp(r'esercizi', caseSensitive: false).hasMatch(exercise)) {
        continue;
      }
      final parsed = _ParsedRow(exercise: exercise)
        ..notes = noteLines.join('\n').trim()
        ..recovery = programming['Rec/Som'] ?? ''
        ..fallbackProgramming = weekLabels
            .map((label) => programming[label] ?? '')
            .where((value) => value.isNotEmpty)
            .join(' ');
      for (final label in weekLabels) {
        parsed.programming[label] = programming[label] ?? '';
      }
      parsedRows.add(parsed);
    }

    return _ParsedPage(
      dayCode: dayCode,
      weekLabels: weekLabels,
      rows: parsedRows,
    );
  }

  static List<_PositionedRow> _positionedRows(List<TrainerPdfTextItem> source) {
    final sorted = [...source]
      ..sort((a, b) {
        if ((a.y - b.y).abs() <= 2.5) return a.x.compareTo(b.x);
        return a.y.compareTo(b.y);
      });
    final rows = <_PositionedRow>[];
    for (final item in sorted) {
      final previous = rows.isEmpty ? null : rows.last;
      if (previous != null && (previous.y - item.y).abs() <= 2.5) {
        previous.items.add(item);
      } else {
        rows.add(_PositionedRow(y: item.y, items: [item]));
      }
    }
    for (final row in rows) {
      row.items.sort((a, b) => a.x.compareTo(b.x));
    }
    return rows;
  }

  static List<_PdfColumn> _headerColumns(List<TrainerPdfTextItem> items) {
    final sorted = [...items]..sort((a, b) => a.x.compareTo(b.x));
    final columns = <_PdfColumn>[];
    for (var index = 0; index < sorted.length; index++) {
      final item = sorted[index];
      final text = item.text.toLowerCase();
      String? label;
      var width = item.width;
      if (RegExp(r'esercizi?').hasMatch(text)) {
        label = 'exercise';
      } else if (RegExp(r'^notes?$').hasMatch(text)) {
        label = 'notes';
      } else if (text.contains('scarico')) {
        label = 'Scarico';
      } else if (RegExp(r'rec\s*/\s*som').hasMatch(text)) {
        label = 'Rec/Som';
      } else {
        final match = RegExp(r'sett(?:imana)?\s*([1-9])').firstMatch(text);
        if (match != null) {
          label = 'Sett ${match.group(1)}';
        } else if (RegExp(r'^sett(?:imana)?$').hasMatch(text) &&
            index + 1 < sorted.length) {
          final number = RegExp(r'^[1-9]$').firstMatch(sorted[index + 1].text);
          if (number != null) {
            label = 'Sett ${number.group(0)}';
            width = sorted[index + 1].x + sorted[index + 1].width - item.x;
            index++;
          }
        }
      }
      if (label != null && !columns.any((column) => column.label == label)) {
        columns.add(_PdfColumn(label: label, x: item.x, width: width));
      }
    }
    columns.sort((a, b) => a.x.compareTo(b.x));
    return columns;
  }

  static List<double> _columnBoundaries(
    List<_PdfColumn> columns,
    double pageWidth,
  ) {
    final boundaries = <double>[
      0,
      for (var index = 1; index < columns.length; index++)
        (columns[index - 1].centerX + columns[index].centerX) / 2,
      pageWidth,
    ];
    final scheduleIndices = <int>[
      for (var index = 0; index < columns.length; index++)
        if (columns[index].label.startsWith('Sett ') ||
            columns[index].label == 'Scarico')
          index,
    ];
    if (scheduleIndices.length < 2) return boundaries;

    final spacings = <double>[
      for (var index = 1; index < scheduleIndices.length; index++)
        columns[scheduleIndices[index]].centerX -
            columns[scheduleIndices[index - 1]].centerX,
    ]..sort();
    final scheduleWidth = spacings[spacings.length ~/ 2];
    final firstSchedule = scheduleIndices.first;
    final lastSchedule = scheduleIndices.last;
    if (firstSchedule > 0) {
      boundaries[firstSchedule] =
          columns[firstSchedule].centerX - scheduleWidth / 2;
    }
    if (lastSchedule + 1 < columns.length) {
      boundaries[lastSchedule + 1] =
          columns[lastSchedule].centerX + scheduleWidth / 2;
    }

    final notesIndex = columns.indexWhere((column) => column.label == 'notes');
    if (notesIndex > 0 && notesIndex + 1 == firstSchedule) {
      boundaries[notesIndex] =
          2 * columns[notesIndex].centerX - boundaries[firstSchedule];
    }
    return boundaries;
  }

  _ParsedPage? _parsePage(String source) {
    final rawLines = source.replaceAll('\r', '').split('\n');
    final fullText = rawLines.join(' ');
    final dayMatch = RegExp(
      r'giorno\s+([a-g])',
      caseSensitive: false,
    ).firstMatch(fullText);
    if (dayMatch == null) return null;
    final dayCode = dayMatch.group(1)!.toUpperCase();
    final weekLabels = <String>[];
    for (final match in RegExp(
      r'(?:sett(?:imana)?\s*([1-9])|scarico)',
      caseSensitive: false,
    ).allMatches(fullText)) {
      final label = match.group(1) == null
          ? 'Scarico'
          : 'Sett ${match.group(1)}';
      if (!weekLabels.contains(label)) weekLabels.add(label);
    }

    final rows = <_ParsedRow>[];
    _ParsedRow? current;
    var tableStarted = false;
    for (final rawLine in rawLines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (RegExp(r'esercizi', caseSensitive: false).hasMatch(line)) {
        tableStarted = true;
        continue;
      }
      if (!tableStarted &&
          !RegExp(r'giorno\s+[a-g]', caseSensitive: false).hasMatch(line)) {
        continue;
      }
      if (_isIgnored(line)) continue;

      final cells = rawLine
          .split(RegExp(r'\s{2,}|\t+|\s*\|\s*'))
          .map(_normalize)
          .where((cell) => cell.isNotEmpty)
          .toList();
      if (cells.length >= 2 && !_isProgramming(cells.first)) {
        if (current != null) rows.add(current);
        current = _rowFromCells(cells, weekLabels);
        continue;
      }

      final text = _normalize(line);
      if (current == null || !_isProgramming(text)) {
        if (_looksLikeExercise(text)) {
          if (current != null) rows.add(current);
          current = _ParsedRow(exercise: text);
        }
      } else {
        current.fallbackProgramming = [
          current.fallbackProgramming,
          text,
        ].where((value) => value.isNotEmpty).join(' ');
      }
    }
    if (current != null) rows.add(current);
    return _ParsedPage(
      dayCode: dayCode,
      weekLabels: weekLabels,
      rows: rows.where((row) => row.exercise.isNotEmpty).toList(),
    );
  }

  _ParsedRow _rowFromCells(List<String> cells, List<String> weeks) {
    final row = _ParsedRow(exercise: cells.first);
    final tail = cells.skip(1).toList();
    final expectedProgramming = weeks.length;
    if (tail.length > expectedProgramming + 1) row.notes = tail.removeAt(0);
    if (tail.length > expectedProgramming) row.recovery = tail.removeLast();
    for (var i = 0; i < weeks.length && i < tail.length; i++) {
      row.programming[weeks[i]] = tail[i];
    }
    row.fallbackProgramming = tail.join(' ');
    return row;
  }

  static String _normalize(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').replaceAll('’', "'").trim();

  static bool _isProgramming(String value) {
    final text = value.toLowerCase();
    return RegExp(r'\d').hasMatch(text) ||
        text.contains('amrap') ||
        text.contains('emom') ||
        text.contains('rt') ||
        text.contains('tot') ||
        text.contains('round') ||
        text.contains('kg') ||
        text.contains('no ') ||
        text.contains('@') ||
        text.contains('incremento');
  }

  static bool _looksLikeExercise(String value) =>
      value.length >= 3 &&
      !RegExp(
        r'^(giorno|sett|scarico|note|rec/som)',
        caseSensitive: false,
      ).hasMatch(value);

  static bool _isIgnored(String value) => RegExp(
    r'alessio di buccio|streetlifting|dibbux@gmail\.com|^info\s',
    caseSensitive: false,
  ).hasMatch(value);

  static int _weekOrder(String value) {
    final number = int.tryParse(
      RegExp(r'\d+').firstMatch(value)?.group(0) ?? '',
    );
    return number ?? 999;
  }
}

class _ParsedPage {
  const _ParsedPage({
    required this.dayCode,
    required this.weekLabels,
    required this.rows,
  });
  final String dayCode;
  final List<String> weekLabels;
  final List<_ParsedRow> rows;
}

class _ParsedRow {
  _ParsedRow({required this.exercise});
  final String exercise;
  String notes = '';
  String recovery = '';
  String fallbackProgramming = '';
  final Map<String, String> programming = {};
}

class _PositionedRow {
  _PositionedRow({required this.y, required this.items});

  final double y;
  final List<TrainerPdfTextItem> items;

  String get text => items.map((item) => item.text).join(' ').trim();
}

class _PdfColumn {
  const _PdfColumn({required this.label, required this.x, required this.width});

  final String label;
  final double x;
  final double width;

  double get centerX => x + width / 2;
}

class _ExerciseGroup {
  _ExerciseGroup({required this.lines, required this.minY, required this.maxY});

  final List<_PositionedRow> lines;
  final double minY;
  double maxY;
}
