import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment/payment.dart';
import 'package:statera/data/services/payment_service.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/utils/utils.dart';

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
  late String _enteredPaymentValue;

  @override
  initState() {
    _balanceController.text =
        widget.payment.value.toStringAsFixed(2).toString();
    _enteredPaymentValue = widget.payment.value.toStringAsFixed(2).toString();
    _balanceController.addListener(() => setState(() {
          _enteredPaymentValue = _balanceController.text;
        }));
    super.initState();
  }

  double get balanceToPay => double.tryParse(this._enteredPaymentValue) ?? 0;

  bool get currentUserIsReceiving =>
      widget.payment.receiverId == widget.currentUid;

  String get actionWord => currentUserIsReceiving ? 'Receive' : 'Pay';

  String get otherMemberUid => currentUserIsReceiving
      ? widget.payment.payerId
      : widget.payment.receiverId;

  CustomUser get otherMember => widget.group.getMember(otherMemberUid);

  @override
  Widget build(BuildContext context) {
    final paymentService = context.watch<PaymentService>();
    return AlertDialog(
      title: Text(actionWord),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _balanceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Value to $actionWord'),
            inputFormatters: [CommaReplacerTextInputFormatter()],
          ),
          SizedBox(height: 10),
          Text(
            currentUserIsReceiving
                ? 'You aknowledge that you received a payment of ${this.balanceToPay} from ${this.otherMember.name}.'
                : 'At this point you should make a payment (e-Transfer or cash) of ${this.balanceToPay} to ${this.otherMember.name}.',
          ),
        ],
      ),
      actions: [
        CancelButton(),
        FilledButton(
          onPressed: this.balanceToPay < 0.01
              ? null
              : () async {
                  await snackbarCatch(
                    context,
                    () async {
                      widget.payment.value = this.balanceToPay;
                      await paymentService.payOffBalance(
                          payment: widget.payment);
                      Navigator.of(context).pop();
                    },
                    successMessage: currentUserIsReceiving
                        ? 'Successfully received ${this.balanceToPay} from ${this.otherMember.name}'
                        : 'Successfully paid ${this.balanceToPay} to ${this.otherMember.name}',
                  );
                },
          child: Text('$actionWord ${this.balanceToPay}'),
        ),
      ],
    );
  }
}
