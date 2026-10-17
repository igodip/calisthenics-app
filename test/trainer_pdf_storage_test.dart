import 'dart:typed_data';

import 'package:calisync/trainer/pdf/trainer_pdf_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts PDF headers and creates a trainee-scoped storage path', () {
    expect(
      isValidWorkoutPlanPdf(Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2d])),
      isTrue,
    );
    expect(
      workoutPlanPdfStoragePath('trainee-id', 'plan-id'),
      'trainee-id/plan-id.pdf',
    );
  });

  test('rejects data without the PDF header', () {
    expect(isValidWorkoutPlanPdf(Uint8List.fromList([1, 2, 3, 4, 5])), isFalse);
  });
}
