import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/section_title.dart';

import '../../data/models/models.dart';

class PaymentDetailsDialog extends StatelessWidget {
  final Group group;
  final Payment payment;

  const PaymentDetailsDialog({
    Key? key,
    required this.group,
    required this.payment,
  }) : super(key: key);

  void _navigateToExpense(BuildContext context) {
    Navigator.of(context)
        .pushNamed('${ExpensePage.route}/${payment.relatedExpense!.id}');
  }

  @override
  Widget build(BuildContext context) {
    final receiverUid =
        context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    return AlertDialog(
      title: Text('Payment Info'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(group.getMember(payment.payerId).name)),
                Icon(Icons.arrow_forward_rounded),
                Expanded(
                    child: Text(
                  group.getMember(payment.receiverId).name,
                  textAlign: TextAlign.right,
                )),
              ],
            ),
            Divider(),
            SectionTitle('Reason'),
            Text(
              payment.reason ??
                  (payment.hasRelatedExpense
                      ? 'Expense "${payment.relatedExpense!.name}" was ${payment.relatedExpense!.action?.name ?? 'finalized'}.'
                      : 'Manual payment.'),
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
    );
  }
}
