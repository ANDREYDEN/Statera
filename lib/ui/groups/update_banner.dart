import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:statera/data/services/callables.dart';
import 'package:statera/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({Key? key}) : super(key: key);

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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Version $newerVersion is available',
                style: TextStyle(color: Colors.white),
              ),
              ElevatedButton(
                onPressed: _handleUpdate,
                child: Text('Update'),
              )
            ],
          ),
        );
      },
    );
  }

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

  void _handleUpdate() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      launchUrl(Uri.parse(PlatformOption.android.url!));
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      launchUrl(Uri.parse(PlatformOption.ios.url!));
    }
  }
}
