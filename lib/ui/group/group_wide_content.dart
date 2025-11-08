import 'package:flutter/material.dart';
import 'package:statera/ui/expense/expense_details.dart';
import 'package:statera/ui/group/expenses/expense_list.dart';
import 'package:statera/ui/group/members/owings_list.dart';
import 'package:statera/ui/group/settings/group_settings.dart';
import 'package:statera/ui/payments/payment_list.dart';

class GroupWideContent extends StatelessWidget {
  final int navIndex;
  final Widget sideNavBar;

  const GroupWideContent({
    super.key,
    required this.navIndex,
    required this.sideNavBar,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leftPart = null;
    Widget? rightPart = null;

    if (navIndex == 0) {
      leftPart = OwingsList();
      rightPart = PaymentList();
    } else if (navIndex == 1) {
      leftPart = ExpenseList();
      rightPart = ExpenseDetails();
    } else if (navIndex == 2) {
      rightPart = GroupSettings();
    }

    return Row(
      children: [
        sideNavBar,
        if (leftPart != null)
          Flexible(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: leftPart,
              ),
            ),
          ),
        if (rightPart != null) Flexible(flex: 2, child: rightPart),
      ],
    );
  }
}
