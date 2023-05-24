import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/services.dart';

class UnmarkedExpensesBadge extends StatefulWidget {
  final Widget child;
  final String? groupId;

  const UnmarkedExpensesBadge({
    Key? key,
    required this.child,
    this.groupId,
  }) : super(key: key);

  @override
  State<UnmarkedExpensesBadge> createState() => _UnmarkedExpensesBadgeState();
}

class _UnmarkedExpensesBadgeState extends State<UnmarkedExpensesBadge> {
  @override
  Widget build(BuildContext context) {
    GroupService groupService = context.read<GroupService>();
    String uid = context.read<AuthBloc>().uid;

    return StreamBuilder<List<Expense>>(
      stream: groupService.listenForUnmarkedExpenses(widget.groupId, uid),
      builder: (context, snap) {
        print('Got unmarked expenses: ${snap.data?.length}');
        var unmarkedExpenses = snap.data;
        if (unmarkedExpenses == null || unmarkedExpenses.isEmpty)
          return widget.child;

        return Badge.count(count: unmarkedExpenses.length, child: widget.child);
      },
    );
  }
}
