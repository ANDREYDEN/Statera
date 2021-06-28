import 'package:flutter/material.dart';
import 'package:statera/page_scaffold.dart';
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
          Text("Home"),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(ExpenseList.route);
            },
            child: Text("My Expeses"),
          )
        ],
      ),
    );
  }
}
