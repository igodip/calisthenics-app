import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/store_screenshot_scenario.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture App Store screenshots with isolated demo data', (
    tester,
  ) async {
    expect(
      kDebugMode && const bool.fromEnvironment('STORE_SCREENSHOTS'),
      isTrue,
      reason: 'Use the documented screenshot command; never a release build.',
    );
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await captureStoreScreens(
      tester,
      capture: (name) async {
        await binding.takeScreenshot(name);
      },
    );
  });
}
