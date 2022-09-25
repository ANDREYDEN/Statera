import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/authentication/sign_in.dart';

class AuthGuard extends StatelessWidget {
  final Widget Function() builder;

  const AuthGuard({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationsRepository =
                  context.read<NotificationService>();
              final userRepository = context.read<UserRepository>();
    final notificationsCubit = NotificationsCubit(
                notificationsRepository: notificationsRepository,
                userRepository: userRepository,
              )..load(context);;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previousState, currentState) =>
          previousState.status == AuthStatus.unauthenticated &&
          currentState.status == AuthStatus.authenticated,
      listener: (context, state) =>
          notificationsCubit.updateToken(uid: state.user!.uid),
      builder: (context, authState) {
        if (authState.status == AuthStatus.unauthenticated) {
          return BlocProvider(
            create: (context) => notificationsCubit,
            child: BlocProvider<SignInCubit>(
              create: (_) => SignInCubit(context.read<AuthService>()),
              child: SignIn(),
            ),
          );
        }

        notificationsCubit.requestPermission(uid: authState.user!.uid);

        return this.builder();
      },
    );
  }
}
