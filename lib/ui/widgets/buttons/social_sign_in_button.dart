import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    final result = MouseRegion(
      cursor: isLoading ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          key: ValueKey('$type-sign-in-button'),
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Image.asset(
            'images/$assetName',
            semanticLabel: '$type icon',
            height: 40,
            width: 40,
          ),
        ),
      ),
    );

    if (isLoading) {
      return result
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fade(duration: 1.seconds, begin: 1, end: 0.25);
    }

    return result;
  }
}
