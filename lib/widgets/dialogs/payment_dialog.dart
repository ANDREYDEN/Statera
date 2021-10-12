import 'dart:async';

import 'package:flutter/material.dart';
import 'package:statera/models/author.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/widgets/loader.dart';

class PaymentDialog extends StatefulWidget {
  final bool isReceiving;
  final Author receiver;
  final double value;
  final Future Function(double) onPay;

  const PaymentDialog({
    Key? key,
    required this.receiver,
    required this.value,
    required this.onPay,
    this.isReceiving = false,
  }) : super(key: key);

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  TextEditingController _balanceController = TextEditingController();
  StreamController<bool> _paymentStateController = StreamController();

  @override
  initState() {
    _balanceController.text = widget.value.toString();
    _paymentStateController.add(false);
    super.initState();
  }

  @override
  void dispose() {
    _paymentStateController.close();
    super.dispose();
  }

  double get balanceToPay => double.tryParse(this._balanceController.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        (widget.isReceiving ? "Receiving balance" : "Pay off balance") +
            " (${toStringPrice(this.widget.value)})",
      ),
      content: Column(
        children: [
          TextField(
            controller: _balanceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: "Balance"),
          ),
          SizedBox(height: 10),
          Text(
            widget.isReceiving
                ? "You aknowledge that you received a payment of ${toStringPrice(-this.balanceToPay)} from ${this.widget.receiver.name}."
                : "At this point you should make a payment (e-Transfer or cash) of ${toStringPrice(this.balanceToPay)} to ${this.widget.receiver.name}.",
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        StreamBuilder(
          stream: _paymentStateController.stream,
          builder: (context, snapshot) {
            final paymentInProgress =
                !snapshot.hasData || snapshot.data == true;
            return ElevatedButton(
              onPressed: paymentInProgress
                  ? null
                  : () async {
                      _paymentStateController.add(true);
                      await snackbarCatch(
                        context,
                        () => this.widget.onPay(this.balanceToPay),
                        successMessage: widget.isReceiving
                            ? "Successfully received ${toStringPrice(this.balanceToPay)} from ${this.widget.receiver.name}"
                            : "Successfully paid ${toStringPrice(this.balanceToPay)} to ${this.widget.receiver.name}",
                      );
                      Navigator.of(context).pop();
                    },
              child: Text((widget.isReceiving ? "Recieve" : "Pay") +
                      " ${toStringPrice(this.balanceToPay)}"),
            );
          },
        ),
      ],
    );
  }
}
