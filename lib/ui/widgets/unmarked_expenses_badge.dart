import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/services/services.dart';

class UnmarkedExpensesBadge extends StatefulWidget {
  final Widget child;
  final String? groupId;

  const UnmarkedExpensesBadge(
      {Key? key, required this.child, required this.groupId})
      : super(key: key);

  @override
  State<UnmarkedExpensesBadge> createState() => _UnmarkedExpensesBadgeState();
}

class _UnmarkedExpensesBadgeState extends State<UnmarkedExpensesBadge> {
  late Stream<int> unmarkedExpensesStream;

  @override
  void initState() {
    final groupService = context.read<GroupService>();
    final uid = context.read<AuthBloc>().uid;
    unmarkedExpensesStream = groupService
        .listenForUnmarkedExpenses(widget.groupId, uid)
        .map((unmarkedExpenses) => unmarkedExpenses.length);
    super.initState();
  }

  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: unmarkedExpensesStream,
      builder: (context, snap) {
        if (!snap.hasData) return widget.child;

        final numberOfExpenses = snap.data!;
        if (numberOfExpenses == 0) return widget.child;

        return Badge.count(count: numberOfExpenses, child: widget.child);
      },
    );
  }
}
