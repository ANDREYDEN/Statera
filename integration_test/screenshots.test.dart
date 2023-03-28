import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:statera/main.dart' as app;

import 'test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

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
    await binding.takeScreenshot('1_home');

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Isabel'), findsOneWidget);
    await binding.takeScreenshot('2_debts');
    
    await tester.tap(find.text('Isabel'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('5_payments');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    await binding.takeScreenshot('3_expenses');

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('4_expense');
  });
}
