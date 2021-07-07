import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';

class ExpensesPickerDialog extends StatefulWidget {
  final List<Expense> expenses;
  final String consumerUid;

  const ExpensesPickerDialog({
    Key? key,
    required this.expenses,
    required this.consumerUid,
  }) : super(key: key);

  @override
  _ExpensesPickerDialogState createState() => _ExpensesPickerDialogState();
}

class _ExpensesPickerDialogState extends State<ExpensesPickerDialog> {
  List<Expense?> selectedExpenses = [];

  double get selectedExpensesValue =>
      selectedExpenses.fold(0, (previousValue, expense) {
        if (expense == null) return previousValue;

        return previousValue +
            expense.getConfirmedTotalForUser(widget.consumerUid);
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Pay off expenses"),
      content: MultiSelectDialogField(
        title: Text('Expenses'),
        buttonText: Text('Expenses'),
        items: widget.expenses
            .map(
              (expense) => MultiSelectItem<Expense?>(
                expense,
                "${toStringPrice(expense.getConfirmedTotalForUser(widget.consumerUid))} - ${expense.name}",
              ),
            )
            .toList(),
        onConfirm: (List<Expense?> selectedExpenses) {
          setState(() {
            this.selectedExpenses = selectedExpenses;
          });
        },
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            await Future.wait(selectedExpenses
                .where((expense) => expense != null)
                .map((expense) {
              expense!.pay(widget.consumerUid);
              return Firestore.instance.setExpense(expense);
            }));
            Navigator.of(context).pop();
          },
          child: Text("Pay ${toStringPrice(selectedExpensesValue)}"),
        ),
      ],
    );
  }
}
