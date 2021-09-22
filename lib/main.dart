import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:statera/auth_guard.dart';
import 'package:statera/providers/auth_provider.dart';
import 'package:statera/routing/page_path.dart';
import 'package:statera/utils/constants.dart';
import 'package:statera/views/404.dart';
import 'package:statera/views/expense_page.dart';
import 'package:statera/views/group_list.dart';
import 'package:statera/views/sign_in.dart';
import 'package:statera/views/group_page.dart';

import 'providers/group_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (const bool.fromEnvironment('USE_EMULATORS')) {
    // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    print("Emulators intialized");
    // FirebaseFirestore.instance.settings = const Settings(
    //   host: 'localhost:8080',
    //   sslEnabled: false,
    //   persistenceEnabled: false,
    // );
  }

  runApp(Statera());
}

class Statera extends StatefulWidget {
  @override
  _StateraState createState() => _StateraState();
}

class _StateraState extends State<Statera> {
  final List<PagePath> _paths = [
    // PagePath(
    //   isPublic: true,
    //   pattern: '^${SignIn.route}\$',
    //   builder: (context, _) => SignIn(),
    // ),
    PagePath(
      pattern: '^${GroupList.route}\$',
      builder: (context, _) => GroupList(),
    ),
    PagePath(
      pattern: '^${GroupPage.route}/([\\w-]+)\$',
      builder: (context, match) => GroupPage(groupId: match),
    ),
    PagePath(
      pattern: '^${ExpensePage.route}/([\\w-]+)\$',
      builder: (context, match) => ExpensePage(expenseId: match),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      child: MaterialApp(
        title: kAppName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "Nunito",
        ),
        initialRoute: GroupList.route,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) {
              var route = settings.name ?? '/404';
              for (PagePath path in _paths) {
                final regExpPattern = RegExp(path.pattern);
                if (regExpPattern.hasMatch(route)) {
                  final firstMatch = regExpPattern.firstMatch(route);
                  final match =
                      (firstMatch != null && firstMatch.groupCount == 1)
                          ? firstMatch.group(1)
                          : null;
                  return path.isPublic
                      ? path.builder(context, match)
                      : AuthGuard(
                          originalRoute: route,
                          builder: () => path.builder(context, match),
                        );
                }
              }
              return PageNotFound();
            },
          );
        },
      ),
    );
  }
}
