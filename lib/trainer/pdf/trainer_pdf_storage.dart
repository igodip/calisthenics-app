import 'dart:typed_data';

const workoutPlanPdfBucket = 'workout-plan-pdfs';
const maxWorkoutPlanPdfBytes = 25 * 1024 * 1024;

String workoutPlanPdfStoragePath(String traineeId, Object planId) =>
    '$traineeId/$planId.pdf';

bool isValidWorkoutPlanPdf(Uint8List bytes) =>
    bytes.lengthInBytes <= maxWorkoutPlanPdfBytes &&
    bytes.length >= 5 &&
    bytes[0] == 0x25 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x44 &&
    bytes[3] == 0x46 &&
    bytes[4] == 0x2d;
