import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/authentication/sign_in.dart';

class AuthGuard extends StatelessWidget {
  final Widget Function() builder;

  const AuthGuard({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status == AuthStatus.unauthenticated) {
          return BlocProvider<SignInCubit>(
            create: (_) => SignInCubit(context.read<AuthRepository>()),
            child: SignIn(),
          );
        }

        return this.builder();
      },
    );
  }
}
