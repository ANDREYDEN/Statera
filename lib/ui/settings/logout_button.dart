import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/authentication/sign_in_page.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return DangerButton(
            text: 'Log Out',
            onPressed: () async {
              Future.delayed(
                500.milliseconds,
                () => authBloc.add(LogoutRequested()),
              );
              context.goNamed(SignInPage.name);
            },
          );
        },
      ),
    );
  }
}
