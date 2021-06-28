import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  final Widget child;
  final String? title;

  final void Function()? onFabPressed;

  const PageScaffold({
    Key? key,
    required this.child,
    this.title,
    this.onFabPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title ?? ""),
      ),
      body: child,
      floatingActionButton: this.onFabPressed == null
          ? null
          : FloatingActionButton(
              onPressed: this.onFabPressed,
              child: Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
