import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:statera/main.dart' as app;

import 'test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('e2e test', (WidgetTester tester) async {
    tester.binding.setSurfaceSize(Size(600, 1300));
    final isWide = false;

    await app.main();
    await tester.pumpWidget(app.Statera());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Statera'), findsOneWidget);
    await trySignIn(tester);

    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.text('Isabel'), findsOneWidget);

    await tester.tap(find.text('Isabel'));
    await tester.pumpAndSettle(Duration(seconds: 1));

    if (!isWide) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle(Duration(seconds: 1));
  });
}
