import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:statera/models/Author.dart';
import 'package:statera/page_scaffold.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/services/firestore.dart';
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
    return StreamBuilder<User?>(
      stream: Auth.instance.currentUserStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Text(userSnapshot.error.toString());
        }
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }

        User? user = userSnapshot.data;

        return PageScaffold(
          title: "Statera",
          actions: user == null
              ? null
              : [
                  ElevatedButton(
                    onPressed: () {
                      Auth.instance.signOut();
                    },
                    child: Text("Sign Out"),
                  ),
                ],
          child: user == null
              ? ElevatedButton(
                  onPressed: () {
                    Auth.instance.signInWithGoogle();
                  },
                  child: Text("Log In with Google"),
                )
              : Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(ExpenseList.route);
                        },
                        child: Text("My Expeses"),),
                        Text('Owings:'),
                    Flexible(
                      child: FutureBuilder<Map<Author, double>>(
                          future:
                              Firestore.instance.getOwingsForUser(user.uid),
                          builder: (context, membersSnapshot) {
                            if (userSnapshot.hasError) {
                              return Text(userSnapshot.error.toString());
                            }
                            if (userSnapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !membersSnapshot.hasData) {
                              return Text("Loading...");
                            }

                            var owings = membersSnapshot.data!;
                            return ListView.builder(
                              itemCount: owings.length,
                              itemBuilder: (context, index) {
                                var payer = owings.keys.elementAt(index);
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(payer.name),
                                    Text(owings[payer].toString())
                                  ],
                                );
                              },
                            );
                          }),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
