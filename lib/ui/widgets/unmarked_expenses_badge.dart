import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/services.dart';

class UnmarkedExpensesBadge extends StatelessWidget {
  final Widget child;
  final String? groupId;

  const UnmarkedExpensesBadge({
    Key? key,
    required this.child,
    this.groupId,
  }) : super(key: key);

  _badgeBuilder(BuildContext context, String? groupId, String uid) {
    final groupService = context.read<GroupService>();

    return StreamBuilder<List<Expense>>(
      stream: groupService.listenForUnmarkedExpenses(groupId, uid),
      builder: (context, snap) {
        var unmarkedExpenses = snap.data;
        if (unmarkedExpenses == null || unmarkedExpenses.isEmpty) return child;

        return Badge.count(count: unmarkedExpenses.length, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.select((AuthBloc auth) => auth.state.user);

    if (user == null) return Container();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: groupId != null
              ? _badgeBuilder(context, groupId, user.uid)
              : BlocBuilder<GroupCubit, GroupState>(
                  builder: (context, groupState) => groupState is GroupLoaded
                      ? _badgeBuilder(context, groupState.group.id, user.uid)
                      : Container(),
                ),
        )
      ],
    );
  }
}
