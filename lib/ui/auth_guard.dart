import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/authentication/sign_in.dart';

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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status == AuthStatus.unauthenticated) {
          return SignIn(forwardRoute: this.originalRoute);
        }

        return this.builder();
      },
    );
  }
}
