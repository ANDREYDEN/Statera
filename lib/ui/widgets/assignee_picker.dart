import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/author_avatar.dart';

class AssigneePicker extends StatefulWidget {
  final Expense expense;
  final AssigneeController controller;
  const AssigneePicker({
    Key? key,
    required this.expense,
    required this.controller,
  }) : super(key: key);

  @override
  State<AssigneePicker> createState() => _AssigneePickerState();
}

class _AssigneePickerState extends State<AssigneePicker> {
  @override
  initState() {
    widget.controller.value =
        widget.expense.assignees.map((a) => a.uid).toList();
    super.initState();
  }

  List<String> get selectedUids => widget.controller.value;

  bool get onlyAuthorSelected =>
      selectedUids.length == 1 &&
      selectedUids.contains(widget.expense.author.uid);

  @override
  Widget build(BuildContext context) {
    return GroupBuilder(
      builder: (context, group) {
        return Column(
          children: [
            Visibility(
              visible: onlyAuthorSelected || selectedUids.isEmpty,
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
                  borderColor: this.selectedUids.contains(member.uid)
                      ? Colors.green
                      : Colors.transparent,
                  withName: true,
                  onTap: () {
                    setState(() {
                      if (this.selectedUids.contains(member.uid)) {
                        this.selectedUids.remove(member.uid);
                      } else {
                        this.selectedUids.add(member.uid);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class AssigneeController extends ValueNotifier<List<String>> {
  AssigneeController(List<String> value) : super(value);
}
