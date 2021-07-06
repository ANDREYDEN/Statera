import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:statera/services/auth.dart';
import 'package:statera/widgets/page_scaffold.dart';

class RootScaffoldItem {
  IconData icon;
  String label;
  Widget view;

  RootScaffoldItem({
    required this.icon,
    required this.label,
    required this.view,
  });
}

class RootScaffold extends StatefulWidget {
  final List<RootScaffoldItem> items;

  const RootScaffold({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  _RootScaffoldState createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int selectedNavBarItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth.instance.currentUserStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Text(userSnapshot.error.toString());
        }
        final loading = userSnapshot.connectionState == ConnectionState.waiting;

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
          bottomNavBar: BottomNavigationBar(
            items: widget.items
                .map((item) => BottomNavigationBarItem(
                      label: item.label,
                      icon: Icon(item.icon),
                      activeIcon: Icon(
                        item.icon,
                        color: Theme.of(context).primaryColor,
                      ),
                    ))
                .toList(),
            currentIndex: this.selectedNavBarItemIndex,
            onTap: (index) {
              setState(() {
                this.selectedNavBarItemIndex = index;
              });
            },
          ),
          child: loading
              ? Text("Loading...")
              : user == null
                  ? this.noUserView
                  : widget.items[this.selectedNavBarItemIndex].view,
        );
      },
    );
  }

  Widget get noUserView => ElevatedButton(
        onPressed: () {
          Auth.instance.signInWithGoogle();
        },
        child: Text("Log In with Google"),
      );
}
