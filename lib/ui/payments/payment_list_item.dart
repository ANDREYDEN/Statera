import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/utils/helpers.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;
  final String receiverUid;

  const PaymentListItem({
    Key? key,
    required this.payment,
    required this.receiverUid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color paymentColor =
        payment.isReceivedBy(receiverUid) ? Colors.green : Colors.red;

    final groupCubit = context.read<GroupCubit>();

    return ListTile(
      isThreeLine: payment.hasRelatedExpense,
      title: Text(
        "${groupCubit.loadedState.group.currencySign}${payment.isReceivedBy(receiverUid) ? '+' : '-'}${payment.value.toStringAsFixed(2)}",
        style: TextStyle(color: paymentColor),
      ),
      leading: Icon(
        payment.isAdmin
            ? Icons.warning
            : payment.hasRelatedExpense
                ? Icons.receipt_long
                : Icons.paid,
        color: payment.isAdmin
            ? Colors.red
            : Theme.of(context).colorScheme.secondary,
        size: 30,
      ),
      trailing: Icon(
        payment.isReceivedBy(receiverUid)
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
      onTap: payment.isAdmin
          ? () => _displayReason(context)
          : payment.hasRelatedExpense
              ? () => _navigateToExpense(context)
              : null,
    );
  }

  _displayReason(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(payment.reason!),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context), child: Text('OK'))
        ],
      ),
    );
  }

  _navigateToExpense(BuildContext context) {
    Navigator.of(context)
        .pushNamed("${ExpensePage.route}/${payment.relatedExpense!.id}");
  }
}