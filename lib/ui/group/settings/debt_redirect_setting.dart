import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

class DebtRedirectSetting extends StatelessWidget {
  final Group group;

  const DebtRedirectSetting({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final featureService = context.read<FeatureService>();
    if (!featureService.debtRedirectionEnabled) return SizedBox.shrink();

    return SwitchListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Allow members to redirect debt'),
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => DebtRedirectExplainerDialog(),
            ),
            child: Text('Learn more'),
          ),
        ],
      ),
      value: group.supportsDebtRedirection,
      onChanged: (isOn) {
        final groupCubit = context.read<GroupCubit>();

        groupCubit.update((group) {
          group.supportsDebtRedirection = isOn;
        });
      },
    );
  }
}
