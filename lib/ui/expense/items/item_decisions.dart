import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/widgets/edge_fade.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class ItemDecisions extends StatelessWidget {
  final Item item;

  const ItemDecisions({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: GroupBuilder(
        builder: (_, group) => EdgeFade(
          builder: (_, controller) => ListView(
            controller: controller,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [...item.assignees]
                .where((assigneeDecision) => (assigneeDecision.parts ?? 0) > 0)
                .map((assigneeDecision) {
                  var member = group.getMember(assigneeDecision.uid);

                  return Padding(
                    padding: const EdgeInsets.only(right: Spacing.xs_5),
                    child: item.isPartitioned
                        ? UserAvatar(
                            user: member,
                            dimension: 30,
                            extendedText: assigneeDecision.parts.toString(),
                          )
                        : UserAvatar(user: member, dimension: 30),
                  );
                })
                .toList(),
          ),
        ),
      ),
    );
  }
}
