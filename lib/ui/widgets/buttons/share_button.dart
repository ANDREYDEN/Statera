import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final String data;
  final String? copyMessage;
  final void Function()? afterShare;
  final double? iconSize;
  final IconData? webIcon;
  final IconData? mobileIcon;

  const ShareButton({
    Key? key,
    required this.data,
    this.copyMessage,
    this.afterShare,
    this.iconSize,
    this.webIcon = Icons.copy,
    this.mobileIcon = Icons.share,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (kIsWeb) {
          _webShare(context);
        } else {
          _mobileShare();
        }

        afterShare?.call();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(kIsWeb ? webIcon : mobileIcon, size: iconSize),
      ),
    );
  }

  void _webShare(BuildContext context) async {
    ClipboardData clipData = ClipboardData(text: data);
    await Clipboard.setData(clipData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(copyMessage ?? 'Link copied to clipboard'),
      ),
    );
  }

  void _mobileShare() {
    Share.share(data);
  }
}
