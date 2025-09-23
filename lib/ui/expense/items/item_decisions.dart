import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class ItemDecisions extends StatefulWidget {
  final Item item;

  const ItemDecisions({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemDecisions> createState() => _ItemDecisionsState();
}

class _ItemDecisionsState extends State<ItemDecisions> {
  ScrollController _listController = ScrollController();
  bool _showStartBlur = false;
  bool _showEndBlur = true;

  @override
  void initState() {
    _listController.addListener(() {
      if (_listController.position.atEdge) {
        setState(() {
          _showStartBlur = _listController.position.pixels != 0;
          _showEndBlur = _listController.position.pixels == 0;
        });
      } else {
        if (!_showStartBlur || !_showEndBlur) {
          setState(() {
            _showStartBlur = true;
            _showEndBlur = true;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: GroupBuilder(
        builder: (_, group) => ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white.withAlpha(_showStartBlur ? 13 : 255),
              Colors.white,
              Colors.white,
              Colors.white.withAlpha(_showEndBlur ? 13 : 255),
            ],
            stops: [0, 0.2, 0.8, 1],
            tileMode: TileMode.mirror,
          ).createShader(bounds),
          child: ListView(
            controller: _listController,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [...widget.item.assignees]
                .where((assigneeDecision) => (assigneeDecision.parts ?? 0) > 0)
                .map((assigneeDecision) {
                  if (!group.memberExists(assigneeDecision.uid))
                    return Icon(Icons.error);

                  var member = group.getMember(assigneeDecision.uid);

                  if (!widget.item.isPartitioned)
                    return UserAvatar(author: member, dimension: 30);

                  return Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Row(
                          children: [
                            SizedBox(width: 4),
                            Text(assigneeDecision.parts.toString()),
                            UserAvatar(author: member, dimension: 30),
                          ],
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          ),
        ),
      ),
    );
  }
}
