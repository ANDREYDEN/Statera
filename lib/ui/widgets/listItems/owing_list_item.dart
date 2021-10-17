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
  final Author payer;
  final double owing;

  const OwingListItem({
    Key? key,
    required this.payer,
    required this.owing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var groupState = Provider.of<GroupState>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: AuthorAvatar(author: this.payer, withName: true)),
          if (this.owing < 0)
            TextButton(
              onPressed: this.owing.abs() < 0.01
                  ? null
                  : () => this._handlePayment(context, groupState),
              child: Text(toStringPrice(this.owing)),
            )
          else
            ElevatedButton(
              onPressed: this.owing.abs() < 0.01
                  ? null
                  : () => this._handlePayment(context, groupState),
              child: Text("Pay ${toStringPrice(this.owing)}"),
            ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(
              "${GroupPage.route}/${groupState.group.id}${PaymentList.route}/${payer.uid}",
            ),
            icon: Icon(Icons.format_list_bulleted),
          )
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context, GroupState groupState) {
    var payer = Provider.of<AuthenticationViewModel>(context, listen: false).user.uid;

    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        isReceiving: this.owing < 0,
        receiver: this.payer,
        value: this.owing,
        onPay: (value) async {
          final payment = Payment(
            groupId: groupState.group.id,
            payerId: payer,
            receiverId: this.payer.uid,
            value: value,
          );
          await Firestore.instance.payOffBalance(payment: payment);
        },
      ),
    );
  }
}
