import 'package:flutter/material.dart';
import 'package:statera/ui/expense/actions/expense_action.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';

class FinalizeButton extends StatelessWidget {
  final String expenseId;

  const FinalizeButton({Key? key, required this.expenseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProtectedButton(
      buttonType: ButtonType.filled,
      onPressed: () => FinalizeExpenseAction(expenseId)
          .handle(GroupPage.scaffoldKey.currentContext!),
      child: Text('Finalize'),
    );
  }
}
