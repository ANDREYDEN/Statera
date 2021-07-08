import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/expenses_picker_dialog.dart';

class OwingListItem extends StatelessWidget {
  final Author payer;
  final List<Expense> outstandingExpenses;

  const OwingListItem({
    Key? key,
    required this.payer,
    required this.outstandingExpenses,
  }) : super(key: key);

  double getPotentialOwing(consumerUid) => this.outstandingExpenses.fold(
        0,
        (previousValue, expense) =>
            previousValue + expense.getPotentialTotalForUser(consumerUid),
      );

  double getConfirmedOwing(consumerUid) =>
      this.outstandingExpenses.fold(0, (previousValue, expense) {
        if (!expense.isReadyToBePaidFor) return previousValue;
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
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  handlePayment(context, authVm.user.uid);
                },
                child: Text(
                  "Pay ${toStringPrice(this.getConfirmedOwing(authVm.user.uid))}",
                ),
              ),
              Text(
                "Future estimation: ${toStringPrice(this.getPotentialOwing(authVm.user.uid))}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  void handlePayment(BuildContext context, String consumerUid) {
    showDialog(
      context: context,
      builder: (context) => ExpensesPickerDialog(
        expenses: this
            .outstandingExpenses
            .where((expense) => expense.isReadyToBePaidFor)
            .toList(),
        consumerUid: consumerUid,
      ),
    );
  }
}
