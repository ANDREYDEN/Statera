import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/loading_text.dart';
import 'package:statera/ui/widgets/price_text.dart';

class CurrentDebt extends StatelessWidget {
  final String otherMemberId;

  const CurrentDebt({super.key, required this.otherMemberId});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();

    return GroupBuilder(
      builder: (context, group) {
        final balance = group.balance[authBloc.uid]![otherMemberId]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You owe'),
            PriceText(value: balance, textStyle: TextStyle(fontSize: 32)),
          ],
        );
      },
      loadingWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You owe'),
          LoadingText(height: 45, width: 100),
        ],
      ),
      loadOnError: true,
    );
  }
}
