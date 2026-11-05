import 'package:flutter/material.dart';
import 'package:statera/ui/contacts/add_contact_button.dart';
import 'package:statera/ui/widgets/list_empty.dart';

class EmptyContactsList extends StatelessWidget {
  const EmptyContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListEmpty(
          text: 'Start by adding a contact',
          actions: [AddContactButton()],
          direction: Axis.horizontal,
        ),
      ],
    );
  }
}
