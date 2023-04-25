import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/payments/payment_details_dialog.dart';
import 'package:statera/utils/helpers.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;

  const PaymentListItem({
    Key? key,
    required this.payment,
  }) : super(key: key);

  void _handleTap(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider<AuthBloc>.value(
        value: context.read<AuthBloc>(),
        child: PaymentDetailsDialog(payment: payment, group: group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    Color paymentColor = payment.isReceivedBy(uid) ? Colors.red : Colors.green;

    return GroupBuilder(
      builder: (context, group) {
        final paymentItem = ListTile(
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
            "${group.currencySign}${payment.isReceivedBy(uid) ? '+' : '-'}${payment.value.toStringAsFixed(2)}",
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
            payment.isReceivedBy(uid)
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: paymentColor,
            size: 30,
          ),
          onTap: () => _handleTap(context, group),
        );

        if (!payment.viewedBy.contains(uid)) {
          return paymentItem.animate().fadeIn(duration: Duration(seconds: 1));
        }

        return paymentItem;
      },
    );
  }
}
