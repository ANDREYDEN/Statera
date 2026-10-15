import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/authentication/user_builder.dart';
import 'package:statera/ui/contact/contact_header/settle_debt_button.dart';
import 'package:statera/ui/contact/contact_header/total_debt_text.dart';
import 'package:statera/ui/widgets/payment_info.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class ContactHeader extends StatelessWidget {
  const ContactHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: UserBuilder(
          loadingWidget: _ContactHeaderContent(
            contact: CustomUser.fake(),
            contactLoading: true,
            totalDebt: null,
          ),
          errorBuilder: (context, error) => Text(error.error.toString()),
          builder: (context, contact) {
            final uid = context.watch<AuthBloc>().uid;
            final userRepository = context.read<UserRepository>();

            return StreamBuilder<List<Group>>(
              stream: userRepository.sharedGroupsStream(uid, contact.uid),
              builder: (context, snap) {
                final groups = snap.data;
                final totalDebt = groups == null
                    ? null
                    : userRepository.getTotalDebt(groups, uid, contact.uid);

                return _ContactHeaderContent(
                  contact: contact,
                  contactLoading: false,
                  totalDebt: totalDebt,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ContactHeaderContent extends StatelessWidget {
  final CustomUser contact;
  final bool contactLoading;
  final double? totalDebt;

  const _ContactHeaderContent({
    required this.contact,
    required this.contactLoading,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            UserAvatar(user: contact, loading: contactLoading, dimension: 100),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TotalDebtText(totalDebt: totalDebt),
                  PaymentInfo(user: contact),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettleDebtButton(contactName: contact.name, totalDebt: totalDebt),
      ],
    );
  }
}
