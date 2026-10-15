import 'package:flutter/material.dart';
import 'package:statera/ui/contacts/add_contact_dialog.dart';

class AddContactButton extends StatelessWidget {
  const AddContactButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 100,
        width: 100,
        child: IconButton.outlined(
          onPressed: () => AddContactDialog.show(context),
          icon: const Icon(Icons.person_add),
          iconSize: 60,
        ),
      ),
    );
  }
}
