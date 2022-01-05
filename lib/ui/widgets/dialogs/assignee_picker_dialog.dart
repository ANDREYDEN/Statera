import 'package:flutter/material.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/group_builder.dart';

class AssigneePickerDialog extends StatefulWidget {
  final Expense expense;

  const AssigneePickerDialog({Key? key, required this.expense})
      : super(key: key);

  @override
  _AssigneePickerDialogState createState() => _AssigneePickerDialogState();
}

class _AssigneePickerDialogState extends State<AssigneePickerDialog> {
  late List<String> _selectedUids;

  @override
  initState() {
    _selectedUids =
        widget.expense.assignees.map((assignee) => assignee.uid).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick Assignees'),
      content: Container(
        width: 200,
        child: GroupBuilder(
          builder: (context, group) {
            return ListView.builder(
              itemCount: group.members.length,
              itemBuilder: (context, index) {
                final member = group.members[index];

                return AuthorAvatar(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  author: member,
                  borderColor: this._selectedUids.contains(member.uid)
                      ? Colors.green
                      : Colors.transparent,
                  withName: true,
                  onTap: () {
                    setState(() {
                      if (this._selectedUids.contains(member.uid)) {
                        this._selectedUids.remove(member.uid);
                      } else {
                        this._selectedUids.add(member.uid);
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            widget.expense.updateAssignees(this._selectedUids);
            await ExpenseService.instance.updateExpense(widget.expense);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
