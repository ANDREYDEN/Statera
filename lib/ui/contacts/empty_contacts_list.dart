import 'package:flutter/material.dart';

class EmptyContactsList extends StatelessWidget {
  const EmptyContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      label: Text('Add Contact'),
      icon: Icon(Icons.add),
    );
  }
}
