import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/author_avatar.dart';

class AssigneePicker extends StatefulWidget {
  final Expense expense;
  final AssigneeController controller;
  final void Function(List<String> value)? onChange;

  const AssigneePicker({
    Key? key,
    required this.expense,
    required this.controller,
    this.onChange,
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

  @override
  Widget build(BuildContext context) {
    return GroupBuilder(
      builder: (context, group) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.controller.value.isEmpty,
              child: Text(
                'Please select at least one assignee',
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: group.members.map((member) {
                return AuthorAvatar(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  author: member,
                  borderColor: widget.controller.value.contains(member.uid)
                      ? Colors.green
                      : Colors.transparent,
                  withName: true,
                  onTap: () {
                    setState(() {
                      if (widget.controller.value.contains(member.uid)) {
                        widget.controller.value.remove(member.uid);
                      } else {
                        widget.controller.value.add(member.uid);
                      }
                    });
                    widget.onChange?.call(widget.controller.value);
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
  AssigneeController({List<String>? value}) : super(value ?? []);
}
