import 'package:flutter/material.dart';

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return SizedBox.shrink();

        var newerVersion = '1.0.0';

        return Container(
          color: Colors.green,
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Version $newerVersion is available'),
              ElevatedButton(onPressed: () {}, child: Text('Update'))
            ],
          ),
        );
      },
    );
  }
}
