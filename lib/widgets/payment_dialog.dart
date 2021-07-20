import 'package:flutter/material.dart';
import 'package:statera/models/author.dart';
import 'package:statera/utils/helpers.dart';

class PaymentDialog extends StatefulWidget {
  final Author receiver;
  final double value;
  final Future Function(double) onPay;

  const PaymentDialog({
    Key? key,
    required this.receiver,
    required this.value,
    required this.onPay,
  }) : super(key: key);

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  TextEditingController balanceController = TextEditingController();
  late String inputValue;

  @override
  initState() {
    balanceController.text = inputValue = widget.value.toString();
    balanceController.addListener(() {
      setState(() {
        inputValue = balanceController.text;
      });
    });
    super.initState();
  }

  double get balanceToPay => double.tryParse(this.balanceController.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Pay off balance (${toStringPrice(this.widget.value)})"),
      content: Column(
        children: [
          // TODO: disable paying over balance or negative
          TextField(
            controller: balanceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: "Balance"),
          ),
          SizedBox(height: 10),
          Text(
            "At this point you should make a payment (e-Transfer or cash) of ${toStringPrice(this.balanceToPay)} to ${this.widget.receiver.name}.",
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            await snackbarCatch(
              context,
              () => this.widget.onPay(this.balanceToPay),
              successMessage:
                  "Successfully paid ${toStringPrice(this.balanceToPay)} to ${this.widget.receiver.name}",
            );
            Navigator.of(context).pop();
          },
          child: Text("Pay ${toStringPrice(this.balanceToPay)}"),
        ),
      ],
    );
  }
}
