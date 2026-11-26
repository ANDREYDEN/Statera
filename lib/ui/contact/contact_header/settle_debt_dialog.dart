import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/value_objects/aggregated_debt.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/utils/helpers.dart';

class SettleDebtDialog extends StatelessWidget {
  final CustomUser contact;
  final AggregatedDebt totalDebt;

  const SettleDebtDialog({
    super.key,
    required this.contact,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    final amount = totalDebt.render(absolute: true);
    final isOwing = totalDebt.amount > 0;
    final verb = isOwing ? 'paid' : 'received';
    final direction = isOwing ? 'to' : 'from';

    return AlertDialog(
      title: const Text('Settle Debt'),
      content: Text(
        'Please confirm that you $verb $amount $direction ${contact.name}. This action will settle the balance across all shared groups.',
      ),
      actions: [
        CancelButton(),
        ProtectedButton(
          onPressed: () => _settleDebt(context),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Future<void> _settleDebt(BuildContext context) async {
    final coordinationRepository = context.read<CoordinationRepository>();
    final uid = context.read<AuthBloc>().uid;
    final navigator = Navigator.of(context);

    await snackbarCatch(
      context,
      () async {
        await coordinationRepository.settleDebt(
          uid: uid,
          otherUid: contact.uid,
        );
        navigator.pop();
      },
      successMessage: 'Successfully settled debt with ${contact.name}',
      errorMessage: 'Failed to settle debt with ${contact.name}',
    );
  }
}
