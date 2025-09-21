import 'package:flutter/material.dart';

class SocialSignInButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isLoading;
  final String type;

  const SocialSignInButton.google({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.type = 'google',
  }) : super(key: key);

  const SocialSignInButton.apple({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.type = 'apple',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final assetName =
        '${type}_icon_button_${isDarkMode ? 'light' : 'dark'}.png';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Image.asset('images/$assetName'),
        ),
      ),
    );
  }
}
