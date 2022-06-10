import 'package:flutter/material.dart';

class ListEmpty extends StatelessWidget {
  final String text;
  final Icon? icon;
  const ListEmpty({Key? key, required this.text, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              this.text,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 24,
              ),
            ),
          ),
          this.icon != null ? this.icon! : Container(),
        ],
      ),
    );
  }
}
