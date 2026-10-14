import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final directory = Platform.environment['SCREENSHOT_OUTPUT_DIR'];
  if (directory == null || directory.isEmpty) {
    throw StateError('SCREENSHOT_OUTPUT_DIR must be set.');
  }
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      if (!RegExp(r'^(it|en)/0[1-5]-[a-z-]+$').hasMatch(name)) return false;
      final file = File('$directory/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      return true;
    },
  );
}
