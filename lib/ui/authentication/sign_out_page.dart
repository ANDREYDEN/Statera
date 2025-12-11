import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/settings/settings_page.dart';
import 'package:statera/ui/widgets/loader.dart';

class SignOutPage extends StatefulWidget {
  static const String name = 'SignOut';

  const SignOutPage({super.key});

  @override
  State<SignOutPage> createState() => _SignOutPageState();
}

class _SignOutPageState extends State<SignOutPage> {
  @override
  void initState() {
    var authBloc = context.read<AuthBloc>();
    Future.delayed(500.milliseconds, () {
      authBloc.add(LogoutRequested());
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Signing you out...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Text(
                'If you are not redirected shortly, please navigate back to the settings page and try again.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.goNamed(SettingsPage.name),
                child: const Text('Back to Settings'),
              ),
              SizedBox(height: 20),
              Loader(width: 50),
            ],
          ),
        ),
      ),
    );
  }
}
