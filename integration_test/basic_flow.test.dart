import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:statera/main.dart' as app;

import 'test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('screenshot', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.text('Statera'), findsOneWidget);
    await trySignIn(tester);

    expect(find.text('Home'), findsOneWidget);
    await binding.convertFlutterSurfaceToImage(); // Android only
    await binding.takeScreenshot('home');

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Tester'), findsOneWidget);
    await binding.convertFlutterSurfaceToImage(); // Android only
    await binding.takeScreenshot('debts');

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    
    expect(find.text('Pizza Party'), findsOneWidget);
    await binding.convertFlutterSurfaceToImage(); // Android only
    await binding.takeScreenshot('expenses');
  });
}
