import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/ui/group/group_builder.dart';
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
    final owingCubit = context.read<OwingCubit>();
    final isWide = context.read<LayoutState>().isWide;

    return GroupBuilder(
      builder: (context, group) {
        final paymentPageRoute =
            '${GroupPage.route}/${group.id}${PaymentListPage.route}/${member.uid}';
        final owingColor = this.owing >= group.debtThreshold
            ? Theme.of(context).errorColor
            : null;

        return InkWell(
          onTap: () => isWide
              ? owingCubit.load(member.uid)
              : Navigator.of(context).pushNamed(paymentPageRoute),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color.fromARGB(255, 204, 204, 204)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AuthorAvatar(author: this.member, withName: true),
                ),
                PriceText(
                  value: this.owing,
                  textStyle: TextStyle(fontSize: 18, color: owingColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
