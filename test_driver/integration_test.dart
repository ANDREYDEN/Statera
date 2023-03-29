import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (screenshotName, screenshotBytes, [_]) async {
      final File image = File('screenshots/$screenshotName.png');
      image.writeAsBytesSync(screenshotBytes);
      // Return false if the screenshot is invalid.
      return true;
    },
  );
}
