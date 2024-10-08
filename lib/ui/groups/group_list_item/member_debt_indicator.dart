import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/utils/utils.dart';

class MemberDebtIndicator extends StatelessWidget {
  final UserGroup userGroup;
  final DebtDirection debtDirection;

  const MemberDebtIndicator({
    super.key,
    required this.userGroup,
    required this.debtDirection,
  });

  const MemberDebtIndicator.outward({Key? key, required UserGroup userGroup})
      : this(
          key: key,
          debtDirection: DebtDirection.outward,
          userGroup: userGroup,
        );

  const MemberDebtIndicator.inward({Key? key, required UserGroup userGroup})
      : this(
          key: key,
          debtDirection: DebtDirection.inward,
          userGroup: userGroup,
        );

  @override
  Widget build(BuildContext context) {
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);
    final isOutward = debtDirection == DebtDirection.outward;
    final debt = userGroup.getDebt(debtDirection, uid);

    return Visibility(
      visible: !approxEqual(debt, 0),
      child: Row(
        children: [
          Text(debt.toStringAsFixed(2)),
          Icon(
            isOutward
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: isOutward ? Colors.red[400] : Colors.green[400],
          ),
        ],
      ),
    );
  }
}
