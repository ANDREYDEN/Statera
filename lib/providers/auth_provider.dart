import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/viewModels/authentication_vm.dart';

class AuthProvider extends StatelessWidget {
  final Widget child;

  const AuthProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<AuthenticationViewModel>(
          create: (context) => AuthenticationViewModel(),
      builder: (context, _) => this.child,
    );
  }
}
