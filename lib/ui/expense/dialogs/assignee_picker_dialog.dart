import 'package:flutter/material.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';

class AssigneePickerDialog extends StatefulWidget {
  final Expense expense;

  const AssigneePickerDialog({Key? key, required this.expense})
      : super(key: key);

  @override
  _AssigneePickerDialogState createState() => _AssigneePickerDialogState();
}

class _AssigneePickerDialogState extends State<AssigneePickerDialog> {
  late List<String> _selectedUids;
  String _error = '';

  @override
  initState() {
    _selectedUids =
        widget.expense.assignees.map((assignee) => assignee.uid).toList();
    super.initState();
  }

  bool get onlyAuthorSelected =>
      _selectedUids.length == 1 &&
      _selectedUids.contains(widget.expense.author.uid);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick Assignees'),
      content: Container(
        width: 200,
        child: GroupBuilder(
          builder: (context, group) {
            return Column(
              children: [
                Visibility(
                  visible: onlyAuthorSelected || _selectedUids.isEmpty,
                  child: Text(
                    'Please select at least one assignee other than yourself',
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  children: group.members.map((member) {
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
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        CancelButton(),
        ElevatedButton(
          onPressed: _selectedUids.isEmpty || onlyAuthorSelected
              ? null
              : () => Navigator.pop(context, _selectedUids),
          child: Text('Save'),
        ),
      ],
    );
  }
}
