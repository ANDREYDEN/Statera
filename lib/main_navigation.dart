import 'package:flutter/material.dart';
import 'package:statera/main_provider.dart';
import 'package:statera/views/group_list.dart';
import 'package:statera/views/group_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  Map<String, Widget> get widgets => {
        GroupList.route: GroupList(),
        GroupPage.route: GroupPage(),
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MainProvider(
        child: Navigator(
          initialRoute: GroupList.route,
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
