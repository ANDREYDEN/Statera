import 'package:flutter/material.dart';
import 'package:statera/views/expense_list.dart';
import 'package:statera/views/home.dart';
import 'package:statera/widgets/group_scaffold.dart';

class GroupPage extends StatelessWidget {
  static const String route = '/group';

  const GroupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupScaffold(
      items: [
        GroupScaffoldItem(
          icon: Icons.home,
          label: "Home",
          view: Home()
        ),
        GroupScaffoldItem(
          icon: Icons.money,
          label: "Expenses",
          view: ExpenseList(),
        ),
      ],
    );
  }
}
