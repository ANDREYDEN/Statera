import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextLink extends StatelessWidget {
  final String url;
  final String text;

  const TextLink({
    Key? key,
    required this.url,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        launchUrl(Uri.parse(url));
      },
      child: Text(text),
    );
  }
}
