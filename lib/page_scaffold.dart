import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  final Widget child;
  final String? title;

  const PageScaffold({Key? key, required this.child, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title ?? ""),
      ),
      body: child,
    );
  }
}
