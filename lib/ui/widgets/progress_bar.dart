import 'package:flutter/material.dart';

class ProgressPart {
  int progress;
  Color? color;

  ProgressPart({required this.progress, this.color});
}

class ProgressBar extends StatelessWidget {
  final List<ProgressPart> progressParts;

  ProgressBar({Key? key, required this.progressParts}) : super(key: key);

  ProgressBar.progress({Key? key, required int progress})
      : progressParts = [
          ProgressPart(progress: progress, color: Colors.green),
          ProgressPart(progress: 100 - progress, color: Colors.grey[300]!)
        ],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      child: Row(
        children: progressParts.map((part) {
          bool isFirst = progressParts
              .sublist(0, progressParts.indexOf(part))
              .every((part) => part.progress == 0);
          bool isLast = progressParts.indexOf(part) == progressParts.length ||
              progressParts
                  .sublist(progressParts.indexOf(part) + 1)
                  .every((part) => part.progress == 0);
          return Flexible(
            flex: part.progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isFirst ? 10 : 0),
                  topLeft: Radius.circular(isFirst ? 10 : 0),
                  bottomRight: Radius.circular(isLast ? 10 : 0),
                  topRight: Radius.circular(isLast ? 10 : 0),
                ),
                color: part.color,
              ),
            ),
          );
        }).toList(),
        // Flexible(
        //   flex: total - progress,
        //   child: Container(
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.only(
        //         bottomRight: Radius.circular(10),
        //         topRight: Radius.circular(10),
        //         bottomLeft: Radius.circular(progress == 0 ? 10 : 0),
        //         topLeft: Radius.circular(progress == 0 ? 10 : 0),
        //       ),
        //       color: Colors.grey[300],
        //     ),
        //   ),
        // )
      ),
    );
  }
}
