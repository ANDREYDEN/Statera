import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:statera/main.dart' as app;

import 'test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  const deviceName = const String.fromEnvironment('DEVICE_NAME');
  final isWide =
      WidgetsBinding.instance.renderView.configuration.size.width > 1000;

  testWidgets('Screenshot test', (WidgetTester tester) async {
    await app.main();
    await tester.pumpWidget(app.Statera());
    await tester.pumpAndSettle();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await binding.convertFlutterSurfaceToImage();
    }

    expect(find.text('Statera'), findsOneWidget);
    await trySignIn(tester);

    expect(find.text('Home'), findsOneWidget);
    await binding.takeScreenshot('${deviceName}_1_home');

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.text('Isabel'), findsOneWidget);
    if (!isWide) {
      await binding.takeScreenshot('${deviceName}_2_debts');
    }

    await tester.tap(find.text('Isabel'));
    await tester.pumpAndSettle(Duration(seconds: 1));
    await binding.takeScreenshot('${deviceName}_5_payments');

    if (!isWide) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    if (!isWide) {
      await binding.takeScreenshot('${deviceName}_3_expenses');
    }

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle(Duration(seconds: 1));
    await binding.takeScreenshot('${deviceName}_4_expense');
  });
}
