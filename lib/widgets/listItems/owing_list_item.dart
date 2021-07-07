import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/viewModels/authentication_vm.dart';

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
            previousValue + expense.getTotalForUser(consumerUid),
      );

  double getConfirmedOwing(consumerUid) => this.expenses.fold(
        0,
        (previousValue, expense) {
          if (!expense.isReadyToPay) return previousValue;
          return previousValue + expense.getTotalForUser(consumerUid);
        }
      );

  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthenticationViewModel>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(payer.name),
        Text("Potential: \$${this.getPotentialOwing(authVm.user.uid)}"),
        ElevatedButton(
          onPressed: () {
            // TODO: show selection screen
          },
          child: Text("Pay \$${this.getConfirmedOwing(authVm.user.uid)}"),
        ),
      ],
    );
  }
}
