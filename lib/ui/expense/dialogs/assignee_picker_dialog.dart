import 'package:flutter/material.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/ui/widgets/assignee_picker.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';

class AssigneePickerDialog extends StatefulWidget {
  final Expense expense;

  const AssigneePickerDialog({Key? key, required this.expense})
      : super(key: key);

  @override
  _AssigneePickerDialogState createState() => _AssigneePickerDialogState();
}

class _AssigneePickerDialogState extends State<AssigneePickerDialog> {
  final AssigneeController _assigneeController = AssigneeController();
  bool _invalidSelection = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick Assignees'),
      content: Container(
        width: 200,
        child: AssigneePicker(
          controller: _assigneeController,
          expense: widget.expense,
          onChange: (value) => setState(() {
            _invalidSelection = value.isEmpty;
          }),
        ),
      ),
      actions: [
        CancelButton(),
        ElevatedButton(
          onPressed: _invalidSelection
              ? null
              : () => Navigator.pop(context, _assigneeController.value),
          child: Text('Save'),
        ),
      ],
    );
  }
}
