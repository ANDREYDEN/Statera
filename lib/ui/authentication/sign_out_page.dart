import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
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
    return Loader();
  }
}
