import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/ui/widgets/loader.dart';

class NewPaymentsBadge extends StatelessWidget {
  final String memberId;
  final Widget child;

  const NewPaymentsBadge({
    Key? key,
    required this.memberId,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewPaymentsCubit, NewPaymentsState>(
      builder: (context, newPaymentsState) {
        if (newPaymentsState is NewPaymentsLoading) {
          return Center(child: Loader());
        }

        if (newPaymentsState is NewPaymentsError) {
          return Center(child: Text('Error'));
        }

        final newPaymentsCount =
            (newPaymentsState as NewPaymentsLoaded).countForMember(memberId);

        if (newPaymentsCount == 0) return child;

        return Badge.count(count: newPaymentsCount, child: child);
      },
    );
  }
}
