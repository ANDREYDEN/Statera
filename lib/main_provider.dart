import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/viewModels/authentication_vm.dart';

class MainProvider extends StatelessWidget {
  final Widget child;

  const MainProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<AuthenticationViewModel>(
      create: (context) => AuthenticationViewModel(user: User(uid: "asd")),
      builder: (context, _) => this.child,
    );
  }
}
