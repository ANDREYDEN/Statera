import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/data/models/models.dart';

class GroupsBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    List<UserGroup> groups,
    bool isLoading,
    bool isProcessing,
  )
  builder;
  final Widget Function(BuildContext context, String error)? errorBuilder;

  const GroupsBuilder({super.key, required this.builder, this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        final error = state.error;

        if (error != null) {
          return errorBuilder == null
              ? Center(child: Text(error))
              : errorBuilder!(context, error);
        }

        return builder(
          context,
          state.groups ?? [],
          state.isLoading,
          state.isProcessing,
        );
      },
    );
  }
}
