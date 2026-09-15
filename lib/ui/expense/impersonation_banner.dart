import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expense/impersonation_cubit.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class ImpersonationBanner extends StatelessWidget {
  const ImpersonationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final impersonatedUid = context.watch<ImpersonationCubit>().state;
    if (impersonatedUid == null) return const SizedBox.shrink();

    return GroupBuilder(
      builder: (context, group) {
        final member = group.getMember(impersonatedUid);

        return Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  UserAvatar(user: member, dimension: 28),
                  const SizedBox(width: 8),
                  Text('Viewing as ${member.name}'),
                ],
              ),
              TextButton(
                onPressed: () => context.read<ImpersonationCubit>().stop(),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
      },
    );
  }
}
