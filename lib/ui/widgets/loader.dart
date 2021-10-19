import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double? margin;
  final Color? color;

  const Loader({
    Key? key,
    this.margin,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(this.margin ?? 0),
      child: CircularProgressIndicator(color: this.color),
    );
  }
}
