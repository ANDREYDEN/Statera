import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/utils/utils.dart';

class GroupBuilder extends StatelessWidget {
  final Widget Function(BuildContext, Group) builder;
  final Widget Function(BuildContext, GroupError)? errorBuilder;
  final Widget? loadingWidget;

  const GroupBuilder({
    Key? key,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupCubit, GroupState>(
      listener: (groupContext, state) {
        if (state is GroupError) {
          showSnackBar(
            groupContext,
            state.error.toString(),
            color: Colors.red,
          );
        }

        if (state is GroupJoinSuccess) {
          Navigator.pushReplacementNamed(
            context,
            '${GroupPage.route}/${state.group.id}',
          );
        }
      },
      listenWhen: (before, after) =>
          after is GroupError || after is GroupJoinSuccess,
      builder: (groupContext, state) {
        if (state is GroupLoading) {
          return Center(child: loadingWidget ?? Loader());
        }

        if (state is GroupError) {
          return errorBuilder == null
              ? Center(child: Text(state.error.toString()))
              : errorBuilder!(groupContext, state);
        }

        if (state is GroupLoaded) {
          return builder(groupContext, state.group);
        }

        return SizedBox.shrink();
      },
    );
  }
}
