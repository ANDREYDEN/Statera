import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';

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
    AuthenticationViewModel authVm =
        Provider.of<AuthenticationViewModel>(context, listen: false);
    return StreamBuilder<List<Expense>>(
      stream: Firestore.instance
          .listenForUnmarkedExpenses(this.groupId, authVm.user.uid),
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
