import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/viewModels/authentication_vm.dart';

class MainProvider extends StatelessWidget {
  final Widget child;

  const MainProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState != ConnectionState.done) {
          return Container(child: Text("Loading"));
        }

        return Provider<AuthenticationViewModel>(
          create: (context) => AuthenticationViewModel(),
          builder: (context, _) {
            return this.child;
          },
        );
      },
    );
  }
}
