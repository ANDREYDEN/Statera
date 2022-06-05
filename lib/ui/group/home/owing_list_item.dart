import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/payments/payment_list_page.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/price_text.dart';

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

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        "${GroupPage.route}/${groupCubit.loadedState.group.id}${PaymentListPage.route}/${member.uid}",
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration:
            BoxDecoration(border: Border(bottom: BorderSide(color: Color.fromARGB(255, 204, 204, 204)))),
        child: Row(
          children: [
            Expanded(child: AuthorAvatar(author: this.member, withName: true)),
            PriceText(value: this.owing, textStyle: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
