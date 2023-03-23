import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> trySignIn(WidgetTester tester) async {
  var emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextField),
    );
    if (emailField.evaluate().isEmpty) return;

    await tester.enterText(emailField, 'john@example.com');
    var passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextField),
    );
    await tester.enterText(passwordField, 'Qweqwe1!');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
}