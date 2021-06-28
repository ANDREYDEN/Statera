import 'package:flutter/material.dart';
import 'package:statera/views/home.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  Map<String, Widget> get widgets => {Home.route: Home()};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Navigator(
          initialRoute: Home.route,
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
