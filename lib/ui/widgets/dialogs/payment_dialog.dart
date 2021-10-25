import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/states/group_state.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/widgets/protected_elevated_button.dart';
import 'package:statera/utils/helpers.dart';

class PaymentDialog extends StatefulWidget {
  final Payment payment;
  final Group group;
  final String currentUid;

  const PaymentDialog({
    Key? key,
    required this.payment,
    required this.group,
    required this.currentUid,
  }) : super(key: key);

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  TextEditingController _balanceController = TextEditingController();

  @override
  initState() {
    _balanceController.text = widget.payment.value.toString();
    super.initState();
  }

  // double get balanceToPay => double.tryParse(this._balanceController.text) ?? 0;
  String get balanceToPay => toStringPrice(widget.payment.value);

  bool get currentUserIsReceiving =>
      widget.payment.receiverId == widget.currentUid;
  String get otherMemberUid => currentUserIsReceiving
      ? widget.payment.payerId
      : widget.payment.receiverId;
  Author get otherMember => widget.group.getUser(otherMemberUid)!;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(currentUserIsReceiving ? "Receive" : "Pay"),
      content: Column(
        children: [
          // TextField(
          //   controller: _balanceController,
          //   keyboardType: TextInputType.numberWithOptions(decimal: true),
          //   decoration: InputDecoration(labelText: "Balance"),
          // ),
          Text(
            toStringPrice(widget.payment.value),
            style: Theme.of(context).textTheme.headline3,
          ),
          SizedBox(height: 10),
          Text(
            currentUserIsReceiving
                ? "You aknowledge that you received a payment of ${this.balanceToPay} from ${this.otherMember.name}."
                : "At this point you should make a payment (e-Transfer or cash) of ${this.balanceToPay} to ${this.otherMember.name}.",
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        ProtectedElevatedButton(
          onPressed: () async {
            await snackbarCatch(
              context,
              () async {
                await Firestore.instance.payOffBalance(payment: widget.payment);
                Navigator.of(context).pop();
              },
              successMessage: currentUserIsReceiving
                  ? "Successfully received ${this.balanceToPay} from ${this.otherMember.name}"
                  : "Successfully paid ${this.balanceToPay} to ${this.otherMember.name}",
            );
          },
          child: Text((currentUserIsReceiving ? "Recieve" : "Pay") +
              " ${this.balanceToPay}"),
        ),
      ],
    );
  }
}
