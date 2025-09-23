import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double? margin;
  final double? width;

  const Loader({Key? key, this.margin, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(this.margin ?? 0),
      child: CircularProgressIndicator.adaptive(strokeWidth: width ?? 4.0),
    );
  }
}
