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
    return IconButton(
      onPressed: () async {
        await _webShare(context);

        afterShare?.call();
      },
      icon: Icon(
        kIsWeb ? webIcon : mobileIcon,
        size: iconSize,
        color: Theme.of(context).colorScheme.primary,
      ),
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

  /// TODO: retired, needs testing on iOS
  void _mobileShare() {
    Share.share(data);
  }
}
