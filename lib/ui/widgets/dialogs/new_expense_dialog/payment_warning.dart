import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/widgets/inputs/member_picker.dart';

class PaymentWarning extends StatelessWidget {
  final MemberController memberController;

  const PaymentWarning({super.key, required this.memberController});

  @override
  Widget build(BuildContext context) {
    String _currentUid = context.read<AuthBloc>().uid;

    return ListenableBuilder(
      listenable: memberController,
      builder: (context, _) {
        final numberOfOtherAssignees =
            memberController.value.where((uid) => uid != _currentUid).length;
        final _pickedOnlyOneOtherAssignee = numberOfOtherAssignees == 1;
        return Visibility(
          visible: _pickedOnlyOneOtherAssignee,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You have selected only 1 member (other than yourself). Consider making a direct payment instead.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
