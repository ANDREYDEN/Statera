import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/payment.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/states/group_state.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/author_avatar.dart';
import 'package:statera/widgets/dialogs/payment_dialog.dart';

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AuthorAvatar(author: this.payer),
              SizedBox(width: 10),
              Text(this.payer.name),
            ],
          ),
          this.owing.abs() < 0.01
              ? Text(toStringPrice(this.owing))
              : this.owing < 0
                  ? TextButton(
                      onPressed: () => this._handlePayment(context),
                      child: Text(toStringPrice(this.owing)),
                    )
                  : ElevatedButton(
                      onPressed: () => this._handlePayment(context),
                      child: Text("Pay ${toStringPrice(this.owing)}"),
                    ),
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context) {
    var groupState = Provider.of<GroupState>(context);
    var payer = Provider.of<AuthenticationViewModel>(context).user.uid;

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
