import 'package:flutter/material.dart';

class CustomLayoutBuilder extends StatelessWidget {
  final Function(BuildContext, bool) builder;

  const CustomLayoutBuilder({Key? key, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, constraints.maxWidth > 1000),
    );
  }
}
