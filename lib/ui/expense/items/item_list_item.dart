import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/ui/widgets/price_text.dart';

class ItemListItem extends StatelessWidget {
  final Item item;
  final bool showDecisions;
  final void Function(int) onChangePartition;
  final void Function()? onLongPress;

  const ItemListItem({
    Key? key,
    required this.item,
    this.showDecisions = false,
    required this.onChangePartition,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc authBloc) => authBloc.state.user);

    if (user == null) return Container();

    return ListTile(
      title: Text(item.name),
      subtitle: (!showDecisions ||
              item.assignees.every((a) => a.parts == null || a.parts == 0))
          ? null
          : SizedBox(
              height: 40,
              child: GroupBuilder(
                builder: (_, group) => ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: item.assignees
                      .where((assigneeDecision) =>
                          (assigneeDecision.parts ?? 0) > 0)
                      .map((assigneeDecision) {
                    if (!group.memberExists(assigneeDecision.uid))
                      return Icon(Icons.error);
                    var member = group.getMember(assigneeDecision.uid);
                    return Row(
                      children: [
                        if (item.isPartitioned)
                          Text('x${assigneeDecision.parts}'),
                        UserAvatar(
                          margin: const EdgeInsets.only(right: 4),
                          author: member,
                          dimension: 30,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
      trailing: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PriceText(
              value: item.value,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
            ElevatedButton(
              onPressed: () =>
                  this.onChangePartition(item.getAssigneeParts(user.uid) - 1),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: !item.isMarkedBy(user.uid)
                    ? Colors.grey[300]
                    : item.isMarkedBy(user.uid) &&
                            item.getAssigneeParts(user.uid) == 0
                        ? Colors.red[400]
                        : Colors.grey[500],
                padding: EdgeInsets.all(0),
              ),
              child: Icon(
                !item.isMarkedBy(user.uid) || !item.isPartitioned
                    ? Icons.close_rounded
                    : item.isMarkedBy(user.uid) &&
                            item.getAssigneeParts(user.uid) == 0
                        ? Icons.close_rounded
                        : Icons.remove_rounded,
                color: Colors.white,
              ),
            ),
            Text(
              "${item.isMarkedBy(user.uid) ? item.getAssigneeParts(user.uid) : '-'}/${item.partition}",
            ),
            ElevatedButton(
              onPressed: () =>
                  this.onChangePartition(item.getAssigneeParts(user.uid) + 1),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: !item.isMarkedBy(user.uid)
                    ? Colors.grey[300]
                    : item.undefinedParts == 0 &&
                            item.isMarkedBy(user.uid) &&
                            item.getAssigneeParts(user.uid) > 0
                        ? Colors.green[400]
                        : Colors.grey[500],
              ),
              child: Icon(
                !item.isMarkedBy(user.uid) || !item.isPartitioned
                    ? Icons.check_rounded
                    : item.undefinedParts == 0 &&
                            item.isMarkedBy(user.uid) &&
                            item.getAssigneeParts(user.uid) > 0
                        ? Icons.check_rounded
                        : Icons.add_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      onLongPress: onLongPress,
    );
  }
}
