import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/services/contact_repository.dart';
import 'package:statera/ui/contacts/add_contact_button.dart';
import 'package:statera/ui/contacts/contact_list_item.dart';
import 'package:statera/ui/contacts/empty_contacts_list.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/widgets/edge_fade.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsRepository = context.read<ContactRepository>();
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);
    const padding = Spacing.l_20;

    return StreamBuilder(
      stream: contactsRepository.listenForContacts(uid),
      builder: (context, snap) {
        if (snap.error != null) {
          return Center(child: Text(snap.error.toString()));
        }

        final contacts = snap.data ?? [];

        final nameHeight = contacts.isEmpty ? 0 : 15;

        return Container(
          height: ContactListItem.dimention + nameHeight + 2 * padding,
          padding: const EdgeInsets.symmetric(vertical: padding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRad.m_20,
          ),
          child: contacts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: EmptyContactsList(),
                )
              : EdgeFade(
                  builder: (context, controller) => ListView.builder(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    itemCount: contacts.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(left: Spacing.m_10),
                          child: AddContactButton(),
                        );
                      }

                      return ContactListItem(contact: contacts[i - 1]);
                    },
                  ),
                ),
        );
      },
    );
  }
}
