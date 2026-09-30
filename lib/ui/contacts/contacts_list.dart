import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/contact_repository.dart';
import 'package:statera/ui/contacts/empty_contacts_list.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsRepository = context.read<ContactRepository>();
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    return StreamBuilder(
      stream: contactsRepository.listenForContacts(uid),
      builder: (context, snap) {
        final contacts = snap.data ?? [];

        if (contacts.isEmpty) return const EmptyContactsList();

        return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, i) {
            final contact = contacts[i];

            return UserAvatar(
              user: CustomUser(
                uid: contact.uid,
                name: contact.name,
                photoURL: contact.photoURL,
              ),
            );
          },
        );
      },
    );
  }
}
