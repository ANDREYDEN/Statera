import 'package:flutter/material.dart';
import 'package:statera/main_navigation.dart';

void main() {
  runApp(Statera());
}

class Statera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainNavigation(),
    );
  }
}