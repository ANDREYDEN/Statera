import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/contact_repository.dart';
import 'package:statera/ui/contacts/add_contact_button.dart';
import 'package:statera/ui/contacts/empty_contacts_list.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsRepository = context.read<ContactRepository>();
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    return Container(
      padding: const EdgeInsets.all(Spacing.l_20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRad.m_20,
      ),
      child: StreamBuilder(
        stream: contactsRepository.listenForContacts(uid),
        builder: (context, snap) {
          if (snap.error != null) {
            return Center(child: Text(snap.error.toString()));
          }

          final contacts = snap.data ?? [];

          if (contacts.isEmpty) return const EmptyContactsList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: contacts.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return SizedBox(height: 100, child: AddContactButton());
              }

              final contact = contacts[i - 1];

              return UserAvatar(
                margin: const EdgeInsets.only(left: Spacing.m_10),
                user: CustomUser(
                  uid: contact.uid,
                  name: contact.name,
                  photoURL: contact.photoURL,
                ),
                dimension: 100,
                withName: true,
                namePosition: NamePosition.bottom,
              );
            },
          );
        },
      ),
    );
  }
}
