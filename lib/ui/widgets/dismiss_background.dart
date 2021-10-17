import 'package:flutter/material.dart';

class DismissBackground extends StatelessWidget {
  const DismissBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Icon(Icons.delete)],
        ),
      ),
    );
  }
}
