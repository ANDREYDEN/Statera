import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/contact/contact_page.dart';
import 'package:statera/ui/groups/groups_builder.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;

  static double dimention = 100;

  const ContactListItem({super.key, required this.contact});

  double _getSharedBalance(String uid, List<UserGroup> groups) {
    return groups
        .where(
          (group) => group.balance?[uid]?.containsKey(contact.uid) ?? false,
        )
        .fold(
          0.0,
          (total, group) => total + group.balance![uid]![contact.uid]!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    return GroupsBuilder(
      builder: (context, groups, isLoading, isProcessing) {
        final balance = isLoading ? null : _getSharedBalance(uid, groups);

        return UserAvatar(
          margin: const EdgeInsets.only(left: Spacing.m_10),
          user: CustomUser(
            uid: contact.uid,
            name: contact.name,
            photoURL: contact.photoURL,
          ),
          dimension: dimention,
          withName: true,
          namePosition: NamePosition.bottom,
          extendedText: '\$${balance?.toStringAsFixed(2)}',
          extendedTextStyle: TextStyle(
            fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
          ),
          onTap: () => context.goNamed(
            ContactPage.name,
            pathParameters: {'contactId': contact.uid},
          ),
        );
      },
    );
  }
}
