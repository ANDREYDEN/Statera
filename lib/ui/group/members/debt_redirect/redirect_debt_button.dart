import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_view.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class RedirectDebtButton extends StatelessWidget {
  const RedirectDebtButton({super.key});

  @override
  Widget build(BuildContext context) {
    var uid = context.watch<AuthBloc>().uid;
    var groupCubit = context.read<GroupCubit>();

    var redirectDebtFeatureEnabled =
        FirebaseRemoteConfig.instance.getBool('redirect_debt_feature_flag');

    return GroupBuilder(
      builder: (context, group) {
        if (!group.supportsDebtRedirection) return SizedBox.shrink();
        if (!group.canRedirect(uid)) return SizedBox.shrink();
        if (!redirectDebtFeatureEnabled) return SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.bolt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<GroupCubit>.value(
                    value: groupCubit,
                    child: PageScaffold(
                      title: 'Redirect Debt',
                      child: RedirectDebtView(group: group),
                    ),
                  ),
                ),
              );
            },
            label: Text('Redirect Debt'),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(delay: 3.seconds, duration: 1.seconds),
        );
      },
    );
  }
}
