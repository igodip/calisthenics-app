import 'package:flutter_test/flutter_test.dart';

import 'support/store_screenshot_scenario.dart';

void main() {
  testWidgets('store capture visits populated real screens in both languages', (
    tester,
  ) async {
    const width = double.fromEnvironment(
      'SCREENSHOT_TEST_WIDTH',
      defaultValue: 393,
    );
    const height = double.fromEnvironment(
      'SCREENSHOT_TEST_HEIGHT',
      defaultValue: 852,
    );
    tester.view.physicalSize = const Size(width, height);
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
  });
}
