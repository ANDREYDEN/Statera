import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_visual.dart';
import 'package:statera/ui/widgets/section_title.dart';
import 'package:statera/utils/utils.dart';

class RedirectDebtView extends StatelessWidget {
  final Group group;

  const RedirectDebtView({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    var uid = context.read<AuthBloc>().uid;
    var groupCubit = context.read<GroupCubit>();

    final owerUid = group.getMembersThatOweToUser(uid).first;
    final receiverUid = group.getMembersThatUserOwesTo(uid).first;

    final (newOwerDebt, newAuthorDebt, _) = group.estimateRedirect(
      authorUid: uid,
      owerUid: owerUid,
      receiverUid: receiverUid,
    );

    return Padding(
      padding: kMobileMargin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Before', alignment: Alignment.centerLeft),
          RedirectDebtVisual(owerUid: owerUid, receiverUid: receiverUid),
          SizedBox(height: 20),
          SectionTitle('After', alignment: Alignment.centerLeft),
          RedirectDebtVisual(
            owerUid: owerUid,
            receiverUid: receiverUid,
            owerDebt: newOwerDebt,
            receiverDebt: newAuthorDebt,
          ),
          Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                groupCubit.update((group) => group.redirect(
                      authorUid: uid,
                      owerUid: owerUid,
                      receiverUid: receiverUid,
                    ));
                Navigator.pop(context);
              },
              child: Text('Redirect'),
            ),
          )
        ],
      ),
    );
  }
}
