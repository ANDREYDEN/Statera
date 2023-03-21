import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:statera/main.dart' as app;

import 'test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Screenshot flow', (WidgetTester tester) async {
    await app.main();
    await tester.pumpWidget(app.Statera());
    await tester.pumpAndSettle();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await binding.convertFlutterSurfaceToImage();
    }

    expect(find.text('Statera'), findsOneWidget);
    await trySignIn(tester);

    expect(find.text('Home'), findsOneWidget);
    await binding.takeScreenshot('home');

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Tester'), findsOneWidget);
    await binding.takeScreenshot('debts');

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Pizza Party'), findsOneWidget);
    await binding.takeScreenshot('expenses');
  });
}
