import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/ui/views/group_page.dart';
import 'package:statera/ui/views/payment_list.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/utils/helpers.dart';

class OwingListItem extends StatelessWidget {
  final Author member;
  final double owing;

  const OwingListItem({
    Key? key,
    required this.member,
    required this.owing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var groupCubit = context.read<GroupCubit>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: AuthorAvatar(author: this.member, withName: true)),
          Text(
            toStringPrice(this.owing),
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(
              "${GroupPage.route}/${groupCubit.loadedState.group.id}${PaymentList.route}/${member.uid}",
            ),
            icon: Icon(Icons.analytics_outlined),
          )
        ],
      ),
    );
  }
}
