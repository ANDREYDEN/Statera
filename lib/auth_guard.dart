import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/views/sign_in.dart';
import 'package:statera/widgets/page_scaffold.dart';

class AuthGuard extends StatelessWidget {
  final Widget Function() builder;
  final String originalRoute;

  const AuthGuard({
    Key? key,
    required this.builder,
    required this.originalRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: Auth.instance.currentUserStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return PageScaffold(title: 'Loading...', child: Container());
          }

          if (snap.hasError) {
            return SignIn(
              forwardRoute: this.originalRoute,
              error: 'Error: ${snap.error}',
            );
          }

          User? user = snap.data;

          if (user == null) {
            return SignIn(forwardRoute: this.originalRoute,);
          }

          return this.builder();
        });
  }
}
