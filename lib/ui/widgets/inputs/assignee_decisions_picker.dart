import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/inputs/decision_buttons.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/utils/utils.dart';

class AssigneeDecisionsPicker extends StatelessWidget {
  final List<AssigneeDecision> value;
  final int partition;
  final void Function(List<AssigneeDecision>) onChange;

  const AssigneeDecisionsPicker({
    super.key,
    required this.value,
    this.partition = 1,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final item = SimpleItem(
      name: '',
      value: 0,
      partition: partition,
      assignees: value,
    );

    return GroupBuilder(
      builder: (context, group) => ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: value.length,
        itemBuilder: (context, index) {
          final uid = value[index].uid;
          final member = group.getMember(uid);

          return ListTile(
            title: UserAvatar(user: member, withName: true),
            trailing: IntrinsicWidth(
              child: DecisionButtons(
                item: item,
                uid: uid,
                onChangePartition: (parts) => snackbarCatch(context, () {
                  item.setAssigneeDecision(uid, parts);
                  onChange([...item.assignees]);
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}
