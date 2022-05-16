import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:statera/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets(
      'Logging in is successful',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        await binding.takeScreenshot('login_screen');
        final email = find.byType(TextField).first;
        await tester.enterText(email, "user@example.com");

        final password = find.byType(TextField).last;
        await tester.enterText(password, "Qweqwe1!");

        final signInButton = find.byType(ElevatedButton).first;
        await tester.tap(signInButton);

        await tester.pump(Duration(seconds: 5));
      },
    );
  });
}
