import 'package:flutter/material.dart';

class LargeActionButton extends StatelessWidget {
  final void Function() onPressed;
  final String title;
  final String? description;
  final IconData icon;
  final double? width;

  const LargeActionButton({
    super.key,
    required this.onPressed,
    required this.title,
    required this.icon,
    this.description,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        fixedSize: width == null ? null : Size.fromWidth(width!),
      ),
      icon: Icon(icon, size: 30),
      label: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (description != null)
              Text(
                description!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              )
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }
}
