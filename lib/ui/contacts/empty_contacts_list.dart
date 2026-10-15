import 'package:flutter/material.dart';
import 'package:statera/ui/contacts/add_contact_button.dart';

class EmptyContactsList extends StatelessWidget {
  const EmptyContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [AddContactButton()],
    );
  }
}
