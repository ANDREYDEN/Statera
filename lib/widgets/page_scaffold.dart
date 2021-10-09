import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final void Function()? onFabPressed;

  final BottomNavigationBar? bottomNavBar;

  const PageScaffold({
    Key? key,
    required this.child,
    this.title,
    this.onFabPressed,
    this.actions,
    this.bottomNavBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: this.bottomNavBar,
      appBar: AppBar(
        title: Text(
          this.title ?? "",
          overflow: TextOverflow.fade,
        ),
        actions: this.actions,
      ),
      floatingActionButton: this.onFabPressed == null
          ? null
          : FloatingActionButton(
              onPressed: this.onFabPressed,
              child: Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: child,
    );
  }
}
