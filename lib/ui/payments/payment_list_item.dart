import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
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
      builder: (_) => Provider.value(
        value: context.read<LayoutState>(),
        child: BlocProvider<AuthBloc>.value(
          value: context.read<AuthBloc>(),
          child: PaymentDetailsDialog(payment: payment, group: group),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiverUid =
        context.select<AuthBloc, String>((authBloc) => authBloc.uid);

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
