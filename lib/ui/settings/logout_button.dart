import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/ui/authentication/sign_out_page.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: DangerButton(
        text: 'Log Out',
        onPressed: () async {
          context.goNamed(SignOutPage.name);
        },
      ),
    );
  }
}
