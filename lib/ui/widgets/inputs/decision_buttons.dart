import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/styling/index.dart';

/// Accept/deny controls for a single assignee's decision on an [item],
/// supporting partitioned items (more than 1 part per assignee).
class DecisionButtons extends StatelessWidget {
  final Item item;
  final String uid;
  final void Function(int) onChangePartition;
  final bool disabled;

  const DecisionButtons({
    super.key,
    required this.item,
    required this.uid,
    required this.onChangePartition,
    this.disabled = false,
  });

  Color? get _denyButtonBgColor {
    if (!item.isMarkedBy(uid)) return Colors.grey[300];
    if (item.getAssigneeParts(uid) == 0) return Colors.red[400];
    return Colors.grey[500];
  }

  Color? get _acceptButtonBgColor {
    if (!item.isMarkedBy(uid)) return Colors.grey[300];
    if (item.getAssigneeParts(uid) > 0) return Colors.green[400];
    return Colors.grey[500];
  }

  Color _buttonFgColor(Color? bgColor) =>
      bgColor == Colors.grey[300] ? Colors.grey[700]! : Colors.white;

  IconData get _denyButtonIcon =>
      item.isPartitioned && item.getAssigneeParts(uid) > 0
      ? Icons.remove_rounded
      : Icons.close_rounded;

  IconData get _acceptButtonIcon =>
      item.isPartitioned &&
          item.undefinedParts > 0 &&
          item.getAssigneeParts(uid) > 0
      ? Icons.add_rounded
      : Icons.check_rounded;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: disabled
              ? null
              : () => onChangePartition(item.getAssigneeParts(uid) - 1),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRad.s_10),
            backgroundColor: _denyButtonBgColor,
            foregroundColor: _buttonFgColor(_denyButtonBgColor),
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[400],
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
          onPressed: disabled
              ? null
              : () => onChangePartition(item.getAssigneeParts(uid) + 1),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRad.s_10),
            backgroundColor: _acceptButtonBgColor,
            foregroundColor: _buttonFgColor(_acceptButtonBgColor),
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[400],
            padding: EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
          ),
          icon: Icon(_acceptButtonIcon),
        ),
      ],
    );
  }
}
