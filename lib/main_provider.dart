import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';

class MainProvider extends StatelessWidget {
  final Widget child;

  const MainProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationViewModel>(
          create: (context) => AuthenticationViewModel(),
        ),
        Provider<GroupViewModel>(create: (context) => GroupViewModel()),
      ],
      builder: (context, _) => this.child,
    );
  }
}
