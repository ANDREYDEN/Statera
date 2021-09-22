import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
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
    var authVm = Provider.of<AuthenticationViewModel>(context);
    var groupVm = Provider.of<GroupViewModel>(context);

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
                      onPressed: () => this._handlePayment(
                        context,
                        groupVm.group,
                        authVm.user.uid,
                      ),
                      child: Text(toStringPrice(this.owing)),
                    )
                  : ElevatedButton(
                      onPressed: () => this._handlePayment(
                        context,
                        groupVm.group,
                        authVm.user.uid,
                      ),
                      child: Text("Pay ${toStringPrice(this.owing)}"),
                    ),
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context, Group group, String payer) {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        isReceiving: this.owing < 0,
        receiver: this.payer,
        value: this.owing,
        onPay: (value) async {
          group.payOffBalance(
            payerUid: payer,
            receiverUid: this.payer.uid,
            value: value,
          );
          await Firestore.instance.saveGroup(group);
        },
      ),
    );
  }
}
