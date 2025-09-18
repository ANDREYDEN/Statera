import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/repository_registrant.dart';

Future<void> pumpPage(
  Widget page,
  WidgetTester tester, {
  SignInCubit? signInCubit,
}) async {
  Widget content = RepositoryRegistrant(
    firestore: FakeFirebaseFirestore(),
    child: Provider<LayoutState>.value(
      value: LayoutState(BoxConstraints(maxWidth: 600)),
      child: Builder(builder: (context) {
        return MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                name: 'Test',
                path: '/',
                builder: (_, __) => page,
              ),
            ],
          ),
        );
      }),
    ),
  );

  if (signInCubit != null) {
    content = BlocProvider<SignInCubit>(
      create: (_) => signInCubit,
      child: content,
    );
  }
  await tester.pumpWidget(content);
}

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
