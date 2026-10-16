@Timeout(Duration(minutes: 2))
library;

import 'dart:ffi';
import 'dart:io';

import 'package:calisync/trainer/pdf/trainer_pdf_import.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfium_dart/pdfium_dart.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  group('native PDF extraction', () {
    var workerReady = false;
    setUpAll(() async {
      // flutter test does not bundle native plugin libraries. Resolve the
      // pinned host runtime before Flutter's binding overrides HTTP.
      final cache = Directory(
        Platform.environment['PDFRX_CACHE_DIR'] ??
            '${Directory.systemTemp.path}/calisync-pdf-tests',
      );
      await cache.create(recursive: true);
      final modulePath =
          Platform.environment['PDFIUM_PATH'] ??
          await PDFiumDownloader.downloadAndGetPDFiumModulePath(
            cache.path,
          ).timeout(const Duration(seconds: 90));
      // Fail here with a useful loader error, not an unhandled worker error
      // that leaves the import waiting forever.
      DynamicLibrary.open(modulePath);
      Pdfrx.pdfiumModulePath = modulePath;
      Pdfrx.getCacheDirectory = () => cache.path;
      // Explicitly await configuration inside the worker. The pinned engine
      // starts initialization/font tasks concurrently on a cold worker.
      await PdfrxEntryFunctions.instance.compute((String path) {
        Pdfrx.pdfiumModulePath = path;
      }, modulePath);
      workerReady = true;
    });

    tearDownAll(() async {
      if (workerReady) {
        await PdfrxEntryFunctions.instance.stopBackgroundWorker();
      }
    });

    test(
      'replaces the Scarico exercises with the Massimali instruction',
      () async {
        final plan = await const TrainerPdfImportService().read(
          'test/fixtures/pdf_import/igor_6_7_6_8.pdf',
          'Igor 6.7-6.8',
        );
        final maxTests = plan.days.singleWhere(
          (day) => day.week == 5 && day.dayCode == 'C',
        );

        expect(maxTests.weekTitle, 'Scarico');
        expect(maxTests.exercises, hasLength(1));
        expect(maxTests.exercises.single.name, 'MASSIMALI');
        expect(
          maxTests.exercises.single.notes,
          'Chiedi al tuo trainer cosa fare',
        );
        expect(
          plan.days
              .singleWhere((day) => day.week == 5 && day.dayCode == 'A')
              .exercises,
          hasLength(6),
        );
        expect(
          plan.days
              .singleWhere((day) => day.week == 5 && day.dayCode == 'B')
              .exercises,
          hasLength(7),
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}
