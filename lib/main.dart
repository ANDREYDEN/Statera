import 'package:flutter/material.dart';
import 'package:statera/mainNavigation.dart';

void main() {
  runApp(Statera());
}

class Statera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainNavigation(),
    );
  }
}