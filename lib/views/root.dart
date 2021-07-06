import 'package:flutter/material.dart';
import 'package:statera/views/expense_list.dart';
import 'package:statera/views/home.dart';
import 'package:statera/widgets/root_scaffold.dart';

class Root extends StatelessWidget {
  static const String route = '/';

  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      items: [
        RootScaffoldItem(
          icon: Icons.home,
          label: "Home",
          view: Home()
        ),
        RootScaffoldItem(
          icon: Icons.money,
          label: "Expenses",
          view: ExpenseList(),
        ),
      ],
    );
  }
}
