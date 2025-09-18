import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/ui/widgets/buttons/google_sign_in_button.dart';
import 'package:statera/ui/widgets/buttons/apple_sign_in_button.dart';

void main() {
  group('Sign-in Button Tests', () {
    testWidgets('GoogleSignInButton displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {},
              isSignUp: false,
            ),
          ),
        ),
      );

      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('G'), findsOneWidget);
    });

    testWidgets('GoogleSignInButton shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppleSignInButton displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
              isSignUp: false,
            ),
          ),
        ),
      );

      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('AppleSignInButton shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('GoogleSignInButton shows sign up text when isSignUp is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {},
              isSignUp: true,
            ),
          ),
        ),
      );

      expect(find.text('Sign up with Google'), findsOneWidget);
    });

    testWidgets('AppleSignInButton shows sign up text when isSignUp is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
              isSignUp: true,
            ),
          ),
        ),
      );

      expect(find.text('Sign up with Apple'), findsOneWidget);
    });
  });
}