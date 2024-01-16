import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareButton extends StatelessWidget {
  final String data;
  final String? copyMessage;
  final void Function()? afterShare;
  final IconData? webIcon;
  final IconData? mobileIcon;

  const ShareButton({
    Key? key,
    required this.data,
    this.copyMessage,
    this.afterShare,
    this.webIcon = Icons.copy,
    this.mobileIcon = Icons.share,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      label: Text(kIsWeb ? 'Copy' : 'Share'),
      icon: Icon(kIsWeb ? webIcon : mobileIcon),
      onPressed: () async {
        await _webShare(context);

        afterShare?.call();
      },
    );
  }

  Future<void> _webShare(BuildContext context) async {
    ClipboardData clipData = ClipboardData(text: data);
    await Clipboard.setData(clipData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(copyMessage ?? 'Link copied to clipboard'),
      ),
    );
  }
}
