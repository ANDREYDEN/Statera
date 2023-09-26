import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_arrow.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class RedirectDebtVisual extends StatelessWidget {
  final String owerUid;
  final String receiverUid;
  final double? owerDebt;
  final double? receiverDebt;
  final void Function()? onOwerTap;
  final void Function()? onReceiverTap;

  const RedirectDebtVisual({
    super.key,
    required this.owerUid,
    required this.receiverUid,
    this.owerDebt,
    this.receiverDebt,
    this.onOwerTap,
    this.onReceiverTap,
  });

  @override
  Widget build(BuildContext context) {
    var uid = context.read<AuthBloc>().uid;

    return GroupBuilder(builder: (context, group) {
      return Row(
        // mainAxisSize: MainAxisSize.min,

        children: [
          UserAvatar(
            author: group.getMember(owerUid),
            dimension: 75,
            withName: true,
            namePosition: NamePosition.bottom,
            onTap: onOwerTap,
          ),
          Expanded(
            child: RedirectArrow(
              value: owerDebt ?? group.balance[owerUid]![uid]!,
              color: Colors.green,
            ),
          ),
          UserAvatar(
            author: group.getMember(uid),
            dimension: 75,
            withName: true,
            namePosition: NamePosition.bottom,
          ),
          Expanded(
            child: RedirectArrow(
              value: receiverDebt ?? group.balance[uid]![receiverUid]!,
              color: Colors.red,
            ),
          ),
          UserAvatar(
            author: group.getMember(receiverUid),
            dimension: 75,
            withName: true,
            namePosition: NamePosition.bottom,
            onTap: onReceiverTap,
          ),
        ],
      );
    });
  }
}
