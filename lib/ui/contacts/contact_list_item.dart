import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/value_objects/aggregated_debt.dart';
import 'package:statera/ui/contact/contact_page.dart';
import 'package:statera/ui/groups/groups_builder.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/widgets/aggregated_debt_builder.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final int newPaymentsCount;

  static double dimention = 60;

  const ContactListItem({
    super.key,
    required this.contact,
    this.newPaymentsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);
    final preferredCurrencyCode = context.select<UserCubit, String?>(
      (userCubit) => _getPreferredCurrencyCode(userCubit.state),
    );

    return GroupsBuilder(
      builder: (context, groups, isLoading, isProcessing) {
        return AggregatedDebtBuilder(
          parts: isLoading ? null : _getSharedDebtParts(uid, groups),
          preferredCurrencyCode: preferredCurrencyCode,
          errorBuilder: (context) => _buildAvatar(context, balanceText: '?'),
          builder: (context, debt) =>
              _buildAvatar(context, balanceText: debt?.render() ?? '...'),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, {required String balanceText}) {
    return Badge.count(
      count: newPaymentsCount,
      isLabelVisible: newPaymentsCount > 0,
      child: UserAvatar(
        margin: const EdgeInsets.only(left: Spacing.m_10),
        user: CustomUser(
          uid: contact.uid,
          name: contact.name,
          photoURL: contact.photoURL,
        ),
        dimension: dimention,
        withName: true,
        namePosition: NamePosition.bottom,
        extendedText: balanceText,
        extendedTextStyle: TextStyle(fontSize: ContactListItem.dimention * 0.3),
        onTap: () => context.goNamed(
          ContactPage.name,
          pathParameters: {'contactId': contact.uid},
        ),
      ),
    );
  }

  List<DebtPart> _getSharedDebtParts(String uid, List<UserGroup> groups) {
    return groups
        .where(
          (group) => group.balance?[uid]?.containsKey(contact.uid) ?? false,
        )
        .map(
          (group) => (
            currency: group.currency,
            amount: group.balance![uid]![contact.uid]!,
          ),
        )
        .toList();
  }

  String? _getPreferredCurrencyCode(UserState userState) {
    if (userState is! UserLoaded) return null;

    return userState.user.preferredCurrencyCode;
  }
}
