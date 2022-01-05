import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/expense_service.dart';

class UnmarkedExpensesBadge extends StatelessWidget {
  final Widget child;
  final String? groupId;

  const UnmarkedExpensesBadge({
    Key? key,
    required this.child,
    this.groupId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = context.select((AuthBloc auth) => auth.state.user);

    if (user == null) return Container();

    return StreamBuilder<List<Expense>>(
      stream: ExpenseService.instance
          .listenForUnmarkedExpenses(this.groupId, user.uid),
      builder: (context, snap) {
        var unmarkedExpenses = snap.data;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Badge(
                showBadge:
                    unmarkedExpenses != null && unmarkedExpenses.isNotEmpty,
                badgeContent: Text(
                  unmarkedExpenses?.length.toString() ?? "",
                  style: TextStyle(color: Colors.white),
                ),
                toAnimate: false,
                child: this.child,
              ),
            ),
          ],
        );
      },
    );
  }
}
