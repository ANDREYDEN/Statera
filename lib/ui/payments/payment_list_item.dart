import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/section_title.dart';
import 'package:statera/utils/helpers.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;
  final String receiverUid;

  const PaymentListItem({
    Key? key,
    required this.payment,
    required this.receiverUid,
  }) : super(key: key);

  void _navigateToExpense(BuildContext context) {
    Navigator.of(context)
        .pushNamed('${ExpensePage.route}/${payment.relatedExpense!.id}');
  }

  void _handleTap(BuildContext context, Group group) {
    final isWide = context.read<LayoutState>().isWide;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Info'),
        content: SizedBox(
          width: isWide ? 400 : 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(group.getMember(payment.payerId).name),
                  Icon(Icons.arrow_forward_rounded),
                  Text(group.getMember(payment.receiverId).name),
                ],
              ),
              Divider(),
              SectionTitle('Reason'),
              Text(
                payment.reason ??
                    (payment.hasRelatedExpense
                        ? 'Expense finalized'
                        : 'Payment'),
              ),
              SizedBox(height: 20),
              if (payment.oldPayerBalance != null) ...[
                SectionTitle('Balance change'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${group.currencySign}${((payment.isReceivedBy(receiverUid) ? -1 : 1) * payment.oldPayerBalance!).toStringAsFixed(2)}',
                    ),
                    Icon(Icons.arrow_forward_rounded),
                    Text(
                      '${group.currencySign}${((payment.isReceivedBy(receiverUid) ? -1 : 1) * (payment.oldPayerBalance! - payment.value)).toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
        actions: [
          if (payment.hasRelatedExpense) CancelButton(),
          if (payment.hasRelatedExpense)
            ElevatedButton(
              onPressed: () => _navigateToExpense(context),
              child: Text('Go to expense'),
            )
          else
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color paymentColor =
        payment.isReceivedBy(receiverUid) ? Colors.green : Colors.red;

    return GroupBuilder(
      builder: (context, group) {
        return ListTile(
          isThreeLine: payment.hasRelatedExpense,
          leading: Icon(
            payment.isAdmin
                ? Icons.warning_rounded
                : payment.hasRelatedExpense
                    ? Icons.receipt_long_rounded
                    : Icons.paid_rounded,
            color: payment.isAdmin
                ? Colors.red
                : Theme.of(context).colorScheme.secondary,
            size: 30,
          ),
          title: Text(
            "${group.currencySign}${payment.isReceivedBy(receiverUid) ? '+' : '-'}${payment.value.toStringAsFixed(2)}",
            style: TextStyle(color: paymentColor),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                toStringDateTime(payment.timeCreated) ??
                    'Some time in the past',
              ),
              if (payment.hasRelatedExpense) Text(payment.relatedExpense!.name),
            ],
          ),
          trailing: Icon(
            payment.isReceivedBy(receiverUid)
                ? Icons.call_received_rounded
                : Icons.call_made_rounded,
            color: paymentColor,
            size: 30,
          ),
          onTap: () => _handleTap(context, group),
        );
      },
    );
  }
}
