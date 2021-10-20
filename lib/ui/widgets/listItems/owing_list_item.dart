import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/states/group_state.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/views/group_page.dart';
import 'package:statera/ui/views/payment_list.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/dialogs/payment_dialog.dart';
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
    var groupState = Provider.of<GroupState>(context);

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
          ElevatedButton(
            onPressed: this.owing.abs() < 0.01
                ? null
                : () => this._handlePayment(context, groupState),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.attach_money),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(
              "${GroupPage.route}/${groupState.group.id}${PaymentList.route}/${member.uid}",
            ),
            icon: Icon(Icons.analytics_outlined),
          )
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context, GroupState groupState) {
    var currentUid =
        Provider.of<AuthenticationViewModel>(context, listen: false).user.uid;

    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        isReceiving: this.owing < 0,
        receiver: this.member,
        value: this.owing,
        onPay: () async {
          final payment = Payment(
            groupId: groupState.group.id,
            payerId: this.owing < 0 ? this.member.uid : currentUid,
            receiverId: this.owing < 0 ? currentUid : this.member.uid,
            value: this.owing.abs(),
          );
          await Firestore.instance.payOffBalance(payment: payment);
        },
      ),
    );
  }
}
