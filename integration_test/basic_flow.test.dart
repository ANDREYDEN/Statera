import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:statera/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('screenshot', (WidgetTester tester) async {
    await app.main();

    await tester.pumpAndSettle();

    expect(find.text('Statera'), findsOneWidget);

    var emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextField),
    );
    await tester.enterText(emailField, 'admin@example.com');
    var passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextField),
    );
    await tester.enterText(passwordField, 'Qweqwe1!');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    
    await binding.convertFlutterSurfaceToImage(); // Android only
    await binding.takeScreenshot('home');
  });
}
