import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:statera/main.dart' as app;

import 'test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('e2e test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(Size(600, 1300));
    final isWide = false;

    await app.main();
    await tester.pumpWidget(app.Statera());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Statera'), findsOneWidget);
    await trySignIn(tester);

    final groupListItem = find.text('Home');
    expect(groupListItem, findsOneWidget);
    await tester.tap(groupListItem);
    await tester.pumpAndSettle(Duration(seconds: 1));

    final groupMemberListItem = find.text('Isabel');
    expect(groupMemberListItem, findsOneWidget);
    await tester.tap(groupMemberListItem);
    await tester.pumpAndSettle(Duration(seconds: 1));

    if (!isWide) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    final expenceListItem = find.text('Groceries');
    expect(expenceListItem, findsOneWidget);
    await tester.tap(expenceListItem);
    await tester.pumpAndSettle(Duration(seconds: 1));
  });
}
