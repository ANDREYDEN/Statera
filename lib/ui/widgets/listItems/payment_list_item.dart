import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:statera/data/models/payment.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/utils/helpers.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;

  const PaymentListItem({
    Key? key,
    required this.payment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthenticationViewModel>(context);

    return ListTile(
      title: Text(toStringPrice(payment.value)),
      leading: Icon(
        payment.hasRelatedExpense ? Icons.receipt_long : Icons.paid,
        size: 30,
      ),
      trailing: Icon(
        payment.isReceivedBy(authVm.user.uid)
            ? Icons.call_received
            : Icons.call_made,
        color:
            payment.isReceivedBy(authVm.user.uid) ? Colors.green : Colors.red,
        size: 30,
      ),
      subtitle: Text(
          toStringDateTime(payment.timeCreated) ?? "Some time in the past"),
    );
  }
}
