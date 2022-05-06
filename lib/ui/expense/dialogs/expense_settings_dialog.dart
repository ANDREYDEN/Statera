import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/buttons/protected_elevated_button.dart';

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
          SwitchListTile(
            value: _automaticallyAddNewMembers,
            onChanged: (isOn) {
              setState(() {
                _automaticallyAddNewMembers = !_automaticallyAddNewMembers;
              });
            },
            title: Text('Automatically add new members to this expense'),
          ),
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
        ProtectedElevatedButton(
          onPressed: () async {
            widget.expense.acceptNewMembers = _automaticallyAddNewMembers;
            Navigator.pop(context, true);
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
