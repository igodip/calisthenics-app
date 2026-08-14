import 'package:read_pdf_text/read_pdf_text.dart';

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

class TrainerPdfImportService {
  const TrainerPdfImportService();

  Future<TrainerPdfPlan> read(String path, String fileName) async {
    final pages = await ReadPdfText.getPDFtextPaginated(path);
    return parsePages(
      pages,
      fileName.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), ''),
    );
  }

  TrainerPdfPlan parsePages(List<String> pages, String planName) {
    final parsedPages = pages.map(_parsePage).whereType<_ParsedPage>().toList()
      ..sort((a, b) => a.dayCode.compareTo(b.dayCode));
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
          if (programming.trim().isEmpty && page.weekLabels.isNotEmpty) {
            continue;
          }
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
        text.contains('round') ||
        text.contains('kg') ||
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
