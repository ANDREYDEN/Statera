import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/utils/utils.dart';

class GroupBuilder extends StatelessWidget {
  final Widget Function(BuildContext, Group) builder;

  const GroupBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupCubit, GroupState>(
      listener: (groupContext, state) {
        showSnackBar(
          groupContext,
          state is GroupError
              ? state.error.toString()
              : 'Something went wrong while loading the group',
          color: Colors.red,
          duration: Duration.zero,
        );
      },
      listenWhen: (before, after) => after is GroupError,
      builder: (groupContext, state) {
        if (state is GroupLoading) {
          return Center(child: Loader());
        }

        if (state is GroupLoaded) {
          return builder(groupContext, state.group);
        }

        return Container();
      },
    );
  }
}