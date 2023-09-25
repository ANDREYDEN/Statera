import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final Alignment alignment;

  const SectionTitle(this.text, {this.alignment = Alignment.center}) : super();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
