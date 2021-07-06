import 'package:flutter/material.dart';
import 'package:statera/main_provider.dart';
import 'package:statera/views/expense_list.dart';
import 'package:statera/views/root.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  Map<String, Widget> get widgets => {
        Root.route: Root(),
        ExpenseList.route: ExpenseList(),
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MainProvider(
        child: Navigator(
          initialRoute: Root.route,
          onGenerateRoute: (settings) {
            var route = settings.name;
            if (!widgets.containsKey(route))
              throw new Exception("Can not find route $route");
            return MaterialPageRoute(builder: (context) => widgets[route]!);
          },
        ),
      ),
    );
  }
}
