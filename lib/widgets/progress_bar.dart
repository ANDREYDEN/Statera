import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int progress;
  final int total;

  ProgressBar({
    Key? key,
    required this.progress,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      child: Row(
        children: [
          Flexible(
            flex: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(progress == total ? 10 : 0),
                  topRight: Radius.circular(progress == total ? 10 : 0),
                ),
                color: Colors.green[400],
              ),
            ),
          ),
          Flexible(
            flex: total - progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(progress == 0 ? 10 : 0),
                  topLeft: Radius.circular(progress == 0 ? 10 : 0),
                ),
                color: Colors.grey[300],
              ),
            ),
          )
        ],
      ),
    );
  }
}
