import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/styling/index.dart';
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

          return _AssigneeDecisionListItem(
            member: group.getMember(uid),
            item: item,
            onChangePartition: (parts) => snackbarCatch(context, () {
              item.setAssigneeDecision(uid, parts);
              onChange([...item.assignees]);
            }),
          );
        },
      ),
    );
  }
}

class _AssigneeDecisionListItem extends StatelessWidget {
  final CustomUser member;
  final Item item;
  final void Function(int) onChangePartition;

  const _AssigneeDecisionListItem({
    required this.member,
    required this.item,
    required this.onChangePartition,
  });

  Color? get _denyButtonBgColor {
    if (!item.isMarkedBy(member.uid)) return Colors.grey[300];
    if (item.getAssigneeParts(member.uid) == 0) return Colors.red[400];
    return Colors.grey[500];
  }

  Color? get _acceptButtonBgColor {
    if (!item.isMarkedBy(member.uid)) return Colors.grey[300];
    if (item.getAssigneeParts(member.uid) > 0) return Colors.green[400];
    return Colors.grey[500];
  }

  Color _buttonFgColor(Color? bgColor) =>
      bgColor == Colors.grey[300] ? Colors.grey[700]! : Colors.white;

  IconData get _denyButtonIcon => item.isPartitioned &&
          item.getAssigneeParts(member.uid) > 0
      ? Icons.remove_rounded
      : Icons.close_rounded;

  IconData get _acceptButtonIcon =>
      item.isPartitioned &&
          item.undefinedParts > 0 &&
          item.getAssigneeParts(member.uid) > 0
      ? Icons.add_rounded
      : Icons.check_rounded;

  @override
  Widget build(BuildContext context) {
    final uid = member.uid;

    return ListTile(
      title: UserAvatar(user: member, withName: true),
      trailing: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () =>
                  onChangePartition(item.getAssigneeParts(uid) - 1),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRad.s_10),
                backgroundColor: _denyButtonBgColor,
                foregroundColor: _buttonFgColor(_denyButtonBgColor),
                padding: EdgeInsets.all(0),
                visualDensity: VisualDensity.compact,
              ),
              icon: Icon(_denyButtonIcon),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.xs_5),
              child: Visibility(
                visible: item.partition > 1,
                child: Text(
                  "${item.isMarkedBy(uid) ? item.getAssigneeParts(uid) : '-'}/${item.partition}",
                ),
              ),
            ),
            IconButton(
              onPressed: () =>
                  onChangePartition(item.getAssigneeParts(uid) + 1),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRad.s_10),
                backgroundColor: _acceptButtonBgColor,
                foregroundColor: _buttonFgColor(_acceptButtonBgColor),
                padding: EdgeInsets.all(0),
                visualDensity: VisualDensity.compact,
              ),
              icon: Icon(_acceptButtonIcon),
            ),
          ],
        ),
      ),
    );
  }
}
