import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/group/members/new_payments_badge.dart';
import 'package:statera/ui/payments/payment_list_page.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/ui/widgets/price_text.dart';

class OwingListItem extends StatelessWidget {
  final CustomUser member;
  final double owing;

  const OwingListItem({
    Key? key,
    required this.member,
    required this.owing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final owingCubit = context.watch<OwingCubit>();
    final isWide = context.read<LayoutState>().isWide;

    String? selectedMemberUid = null;

    if (owingCubit.state is OwingSelected) {
      selectedMemberUid = (owingCubit.state as OwingSelected).memberId;
    }

    return GroupBuilder(
      builder: (context, group) {
        final paymentPageRoute =
            '${GroupPage.route}/${group.id}${PaymentListPage.route}/${member.uid}';
        final owingColor = this.owing >= group.debtThreshold
            ? Theme.of(context).colorScheme.error
            : null;
        final isAdmin = group.admin.uid == this.member.uid;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ListTile(
            onTap: () => isWide
                ? owingCubit.select(member.uid)
                : context.go(paymentPageRoute),
            selected: selectedMemberUid == member.uid,
            selectedTileColor:
                Theme.of(context).colorScheme.primary.withAlpha(50),
            title: Row(
              children: [
                Expanded(
                  child: UserAvatar(
                    author: this.member,
                    withName: true,
                    withIcon: isAdmin,
                    icon: isAdmin ? Icons.star : null,
                    iconColor: isAdmin ? Colors.yellow : null,
                    iconBackgroudColor: isAdmin ? Colors.black : null,
                  ),
                ),
                NewPaymentsBadge(
                  memberId: member.uid,
                  child: PriceText(
                    value: this.owing,
                    textStyle: TextStyle(fontSize: 18, color: owingColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
