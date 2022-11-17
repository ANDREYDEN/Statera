import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';

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
  late bool _showItemDecisions;

  @override
  void initState() {
    _automaticallyAddNewMembers = widget.expense.settings.acceptNewMembers;
    _showItemDecisions = widget.expense.settings.showItemDecisions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
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
          SwitchListTile(
            value: _showItemDecisions,
            onChanged: (isOn) {
              setState(() {
                _showItemDecisions = !_showItemDecisions;
              });
            },
            title: Text('Show how other people marked each item'),
          ),
        ],
      ),
      actions: [
        CancelButton(),
        ProtectedButton(
          onPressed: () async {
            widget.expense.settings.acceptNewMembers =
                _automaticallyAddNewMembers;
            widget.expense.settings.showItemDecisions = _showItemDecisions;
            Navigator.pop(context, true);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
