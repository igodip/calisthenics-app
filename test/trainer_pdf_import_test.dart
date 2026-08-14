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
}
