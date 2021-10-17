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

    return Row(
      children: [
        Icon(Icons.receipt_long),
        Text(toStringPrice(payment.value)),
        Icon(
          payment.receiverId == authVm.user.uid
              ? Icons.call_received
              : Icons.call_made,
        ),
      ],
    );
  }
}
