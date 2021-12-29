import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

class ExpenseSettingsDialog extends StatefulWidget {
  final Expense expense;
  const ExpenseSettingsDialog({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  State<ExpenseSettingsDialog> createState() => _ExpenseSettingsDialogState();
}

class _ExpenseSettingsDialogState extends State<ExpenseSettingsDialog> {
  late bool _automaticallyAddNewMembers;

  @override
  void initState() {
    _automaticallyAddNewMembers = widget.expense.acceptNewMembers;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _automaticallyAddNewMembers = !_automaticallyAddNewMembers;
                  });
                },
                icon: Icon(
                  _automaticallyAddNewMembers
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                ),
              ),
              Flexible(
                child: Text('Automatically add new members to this expense'),
              )
            ],
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Theme.of(context).errorColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            widget.expense.acceptNewMembers = _automaticallyAddNewMembers;
            await ExpenseService.instance.saveExpense(widget.expense);
            Navigator.pop(context, true);
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
