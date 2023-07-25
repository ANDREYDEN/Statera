import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/actions/expense_action.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';

class FinalizeButton extends StatelessWidget {
  final Expense expense;

  const FinalizeButton({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProtectedButton(
      onPressed: () => FinalizeExpenseAction(expense)
          .handle(GroupPage.scaffoldKey.currentContext!),
      child: Text('Finalize'),
    );
  }
}
