import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/auth_guard.dart';
import 'package:statera/ui/routing/page_path.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/views/404.dart';
import 'package:statera/ui/views/expense_page.dart';
import 'package:statera/ui/views/group_list.dart';
import 'package:statera/ui/views/group_page.dart';
import 'package:statera/ui/views/payment_list.dart';
import 'package:statera/utils/constants.dart';
import 'package:statera/utils/theme.dart';

import 'data/models/models.dart';
import 'data/services/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyAwjBDDegCJ5PbFGKasjcZm13DZrnuCNFA",
        projectId: "statera-0",
        storageBucket: "statera-0.appspot.com",
        messagingSenderId: "630064020417",
        appId: "1:630064020417:web:48fb8194a91bf70ec3cd40"),
  );

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
      builder: (context, matches) => BlocProvider<GroupCubit>(
          create: (context) {
            final groupCubit = GroupCubit();
            groupCubit.load(matches?[0]);
            return groupCubit;
          },
          child: GroupPage(groupId: matches?[0])),
    ),
    PagePath(
      pattern: '^${ExpensePage.route}/([\\w-]+)\$',
      builder: (context, matches) => MultiProvider(
        providers: [
          StreamProvider<Expense>.value(
            value: ExpenseService.instance.listenForExpense(matches?[0]),
            initialData: Expense.empty(),
          ),
          BlocProvider<GroupCubit>(
            create: (context) {
              final groupCubit = GroupCubit();
              groupCubit.loadFromExpense(matches?[0]);
              return groupCubit;
            },
          )
        ],
        child: ExpensePage(expenseId: matches?[0]),
      ),
    ),
    PagePath(
      pattern: '^${GroupPage.route}/([\\w-]+)${PaymentList.route}/([\\w-]+)\$',
      builder: (context, matches) => BlocProvider<GroupCubit>(
        create: (context) {
          final groupCubit = GroupCubit();
          groupCubit.load(matches?[0]);
          return groupCubit;
        },
        child: PaymentList(groupId: matches?[0], otherMemberId: matches?[1]),
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Provider<AuthenticationViewModel>(
      create: (context) => AuthenticationViewModel(),
      builder: (context, _) {
        return MaterialApp(
          title: kAppName,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
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
                    final matches = firstMatch?.groups(
                      List.generate(
                          firstMatch.groupCount, (index) => index + 1),
                    );
                    return SafeArea(
                      child: path.isPublic
                          ? path.builder(context, matches)
                          : AuthGuard(
                              originalRoute: route,
                              builder: () => path.builder(context, matches),
                            ),
                    );
                  }
                }
                return PageNotFound();
              },
            );
          },
        );
      },
    );
  }
}
