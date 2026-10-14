import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/store_screenshot_scenario.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Ahem's square glyphs produce artificial overflows in real app layouts.
    // Load the SDK's bundled Roboto font for meaningful viewport checks.
    final sdk = Platform.environment['FLUTTER_ROOT'];
    if (sdk == null) throw StateError('Set FLUTTER_ROOT to the Flutter SDK.');
    final fonts = Directory('$sdk/bin/cache/artifacts/material_fonts');
    final loader = FontLoader('Roboto');
    for (final file in fonts.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      if (name.startsWith('Roboto-') && name.endsWith('.ttf')) {
        loader.addFont(
          Future.value(ByteData.sublistView(await file.readAsBytes())),
        );
      }
    }
    await loader.load();
  });
  testWidgets(
    'store capture visits populated real screens in both languages',
    (tester) async {
      const width = int.fromEnvironment(
        'SCREENSHOT_TEST_WIDTH',
        defaultValue: 393,
      );
      const height = int.fromEnvironment(
        'SCREENSHOT_TEST_HEIGHT',
        defaultValue: 852,
      );
      tester.view.physicalSize = Size(width.toDouble(), height.toDouble());
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final captured = <String>[];
      await captureStoreScreens(
        tester,
        capture: (name) async => captured.add(name),
      );
      expect(captured, hasLength(10));
      expect(captured.toSet(), hasLength(10));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
