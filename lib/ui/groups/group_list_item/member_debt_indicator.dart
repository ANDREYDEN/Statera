import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';

class MemberDebtIndicator extends StatelessWidget {
  final UserGroup userGroup;

  const MemberDebtIndicator({super.key, required this.userGroup});

  @override
  Widget build(BuildContext context) {
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    return Visibility(
      visible: userGroup.hasDebt(uid),
      child: Row(
        children: [
          Text(userGroup.getDebt(uid).toStringAsFixed(2)),
          Icon(
            Icons.arrow_upward_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }
}
