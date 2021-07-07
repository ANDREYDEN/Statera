import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/expenses_picker_dialog.dart';

class OwingListItem extends StatelessWidget {
  final Author payer;
  final List<Expense> expenses;

  const OwingListItem({
    Key? key,
    required this.payer,
    required this.expenses,
  }) : super(key: key);

  double getPotentialOwing(consumerUid) => this.expenses.fold(
        0,
        (previousValue, expense) =>
            previousValue + expense.getPotentialTotalForUser(consumerUid),
      );

  double getConfirmedOwing(consumerUid) =>
      this.expenses.fold(0, (previousValue, expense) {
        if (!expense.isReadyToPay || expense.paidBy(consumerUid)) return previousValue;
        return previousValue + expense.getConfirmedTotalForUser(consumerUid);
      });

  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthenticationViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(payer.name),
          Text(
              "Not marked: ${toStringPrice(this.getPotentialOwing(authVm.user.uid))}"),
          ElevatedButton(
            onPressed: () {
              handlePayment(context, authVm.user.uid);
            },
            child: Text(
                "Pay ${toStringPrice(this.getConfirmedOwing(authVm.user.uid))}"),
          ),
        ],
      ),
    );
  }

  void handlePayment(BuildContext context, String consumerUid) {
    showDialog(
      context: context,
      builder: (context) => ExpensesPickerDialog(
        expenses:
            this.expenses.where((expense) => expense.isReadyToPay).toList(),
        consumerUid: consumerUid,
      ),
    );
  }
}
