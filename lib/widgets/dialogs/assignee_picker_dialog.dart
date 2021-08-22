import 'package:flutter/material.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/widgets/author_avatar.dart';

class AssigneePickerDialog extends StatefulWidget {
  final Expense expense;
  final Group group;

  const AssigneePickerDialog(
      {Key? key, required this.expense, required this.group})
      : super(key: key);

  @override
  _AssigneePickerDialogState createState() => _AssigneePickerDialogState();
}

class _AssigneePickerDialogState extends State<AssigneePickerDialog> {
  late List<Assignee> _selectedAssignees;

  @override
  initState() {
    _selectedAssignees = [...widget.expense.assignees];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick Assignees'),
      content: Container(
        width: 200,
        child: ListView.builder(
          itemCount: this.widget.expense.assignees.length,
          itemBuilder: (context, index) {
            final assignee = widget.expense.assignees[index];
            final authorOption = widget.group.getUser(assignee.uid);

            if (authorOption == null) return Icon(Icons.error);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AuthorAvatar(
                author: authorOption,
                borderColor: this._selectedAssignees.contains(assignee)
                    ? Colors.green
                    : Colors.transparent,
                withName: true,
                onTap: () {
                  setState(() {
                    if (this._selectedAssignees.contains(assignee)) {
                      this._selectedAssignees.remove(assignee);
                    } else {
                      this._selectedAssignees.add(assignee);
                    }
                  });
                },
              ),
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
            widget.expense.assignees = this._selectedAssignees;
            await Firestore.instance.updateExpense(widget.expense);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
