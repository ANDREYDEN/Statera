import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:statera/data/services/callables.dart';

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({Key? key}) : super(key: key);

  Future<String?> _getNewerVersionIfExists() async {
    String? newerVersion;
    if (defaultTargetPlatform == TargetPlatform.android) {
      newerVersion = await Callables.getLatestAndroidVersion();
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      newerVersion = await Callables.getLatestIOSVersion();
    }

    final currentVersion = await PackageInfo.fromPlatform();
    final currentVersionNumber = currentVersion.version;
    if (newerVersion != currentVersionNumber) {
      return newerVersion;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getNewerVersionIfExists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return SizedBox.shrink();
        }

        var newerVersion = snapshot.data!;

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
