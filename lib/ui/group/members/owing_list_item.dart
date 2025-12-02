import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/members/actions/kick_member_action.dart';
import 'package:statera/ui/group/members/actions/transfer_ownership_action.dart';
import 'package:statera/ui/payments/payment_list_page.dart';
import 'package:statera/ui/widgets/buttons/actions_button.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class OwingListItem extends StatelessWidget {
  final CustomUser member;
  final double owing;
  final int newPaymentsCount;

  const OwingListItem({
    Key? key,
    required this.member,
    required this.owing,
    this.newPaymentsCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final owingCubit = context.watch<OwingCubit>();
    final isWide = context.read<LayoutState>().isWide;
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    String? selectedMemberUid = null;

    if (owingCubit.state is OwingSelected) {
      selectedMemberUid = (owingCubit.state as OwingSelected).memberId;
    }

    return GroupBuilder(
      builder: (context, group) {
        final owingColor = this.owing >= group.debtThreshold
            ? Theme.of(context).colorScheme.error
            : null;
        final isMemberAdmin = group.admin.uid == this.member.uid;
        final isCurrentUserAdmin = group.isAdmin(uid);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ListTile(
            onTap: () => isWide
                ? owingCubit.select(member.uid)
                : context.goNamed(
                    PaymentListPage.name,
                    pathParameters: {
                      'groupId': group.id!,
                      'memberId': member.uid,
                    },
                  ),
            selected: selectedMemberUid == member.uid,
            selectedTileColor: Theme.of(
              context,
            ).colorScheme.primary.withAlpha(50),
            title: Row(
              children: [
                Expanded(
                  child: UserAvatar(
                    author: this.member,
                    withName: true,
                    withIcon: isMemberAdmin,
                    icon: isMemberAdmin ? Icons.star : null,
                    iconColor: isMemberAdmin ? Colors.yellow : null,
                    iconBackgroudColor: isMemberAdmin ? Colors.black : null,
                  ),
                ),
                Badge.count(
                  count: newPaymentsCount,
                  isLabelVisible: newPaymentsCount > 0,
                  child: PriceText(
                    value: this.owing,
                    textStyle: TextStyle(fontSize: 18, color: owingColor),
                  ),
                ),
              ],
            ),
            trailing: isCurrentUserAdmin
                ? ActionsButton(
                    tooltip: 'Admin Actions',
                    actions: [
                      KickMemberAction(group, this.member),
                      TransferOwnershipAction(this.member),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}
