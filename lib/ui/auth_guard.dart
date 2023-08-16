import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/authentication/sign_in.dart';
import 'package:statera/ui/notifications_initializer.dart';

class AuthGuard extends StatelessWidget {
  final Widget Function() builder;
  final bool isHomePage;

  const AuthGuard({
    Key? key,
    required this.builder,
    required this.isHomePage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status == AuthStatus.unauthenticated) {
          return BlocProvider<SignInCubit>(
            create: (_) => SignInCubit(context.read<AuthService>()),
            child: SignIn(),
          );
        }

        return NotificationsInitializer(
          isHomePage: isHomePage,
          child: this.builder(),
        );
      },
    );
  }
}
