import 'package:flutter/material.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/widgets/author_avatar.dart';
import 'package:statera/widgets/custom_stream_builder.dart';

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
        child: CustomStreamBuilder<Group>(
            stream: Firestore.instance.getExpenseGroupStream(widget.expense),
            builder: (context, group) {
              return ListView.builder(
                itemCount: group.members.length,
                itemBuilder: (context, index) {
                  final member = group.members[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: AuthorAvatar(
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
                    ),
                  );
                },
              );
            }),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            widget.expense.updateAssignees(this._selectedUids);
            await Firestore.instance.updateExpense(widget.expense);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
