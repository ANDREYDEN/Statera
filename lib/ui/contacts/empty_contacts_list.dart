import 'package:flutter/material.dart';
import 'package:statera/ui/styling/index.dart';

class EmptyContactsList extends StatelessWidget {
  const EmptyContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton.outlined(
          onPressed: () {},
          icon: const Icon(Icons.person_add),
          iconSize: Spacing.xl_32,
        ),
      ],
    );
  }
}
