import 'package:flutter/material.dart';
import 'package:statera/ui/contacts/add_contact_dialog.dart';
import 'package:statera/ui/contacts/contact_list_item.dart';

class AddContactButton extends StatelessWidget {
  const AddContactButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: ContactListItem.dimention,
        width: ContactListItem.dimention,
        child: IconButton.outlined(
          onPressed: () => AddContactDialog.show(context),
          icon: const Icon(Icons.person_add),
          iconSize: ContactListItem.dimention * 0.5,
        ),
      ),
    );
  }
}
