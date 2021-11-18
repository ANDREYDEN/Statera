import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:statera/data/models/payment.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/views/expense_page.dart';
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
    Color paymentColor =
        payment.isReceivedBy(authVm.user.uid) ? Colors.green : Colors.red;

    return ListTile(
      isThreeLine: payment.hasRelatedExpense,
      title: Text(
        "\$${payment.isReceivedBy(authVm.user.uid) ? '+' : '-'}${payment.value.toStringAsFixed(2)}",
        style: TextStyle(color: paymentColor),
      ),
      leading: Icon(
        payment.hasRelatedExpense ? Icons.receipt_long : Icons.paid,
        color: Theme.of(context).colorScheme.secondary,
        size: 30,
      ),
      trailing: Icon(
        payment.isReceivedBy(authVm.user.uid)
            ? Icons.call_received
            : Icons.call_made,
        color: paymentColor,
        size: 30,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            toStringDateTime(payment.timeCreated) ?? "Some time in the past",
          ),
          if (payment.hasRelatedExpense) Text(payment.relatedExpense!.name),
        ],
      ),
      onTap: payment.hasRelatedExpense
          ? () => Navigator.of(context)
              .pushNamed("${ExpensePage.route}/${payment.relatedExpense!.id}")
          : null,
    );
  }
}