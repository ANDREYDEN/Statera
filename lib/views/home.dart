import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/page_scaffold.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/views/expense_list.dart';

class Home extends StatefulWidget {
  static const String route = '/';

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "Statera",
      child: Column(
        children: [
          StreamBuilder<User?>(
              stream: Auth.instance.currentUserStream(),
              builder: (context, snapshot) {
                print(snapshot);
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading...");
                }

                User? user = snapshot.data;

                return user == null
                    ? ElevatedButton(
                        onPressed: () {
                          Auth.instance.signInWithGoogle();
                        },
                        child: Text("Log In with Google"),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(ExpenseList.route);
                        },
                        child: Text("My Expeses"),
                      );
              }),
        ],
      ),
    );
  }
}
