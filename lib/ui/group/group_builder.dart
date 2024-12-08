import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/loader.dart';

class GroupBuilder extends StatelessWidget {
  final Widget Function(BuildContext, Group) builder;
  final Widget Function(BuildContext, GroupError)? errorBuilder;
  final Widget? loadingWidget;
  final bool loadOnError;
  final void Function(BuildContext, GroupError)? onError;

  const GroupBuilder({
    Key? key,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
    this.loadOnError = false,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupCubit, GroupState>(
      listener: (groupContext, state) {
        if (state is GroupError) {
          onError?.call(groupContext, state);
        }

        if (state is GroupJoinSuccess) {
          context.goNamed(
            GroupPage.name,
            pathParameters: {'groupId': state.group.id!},
          );
        }
      },
      listenWhen: (before, after) =>
          after is GroupError || after is GroupJoinSuccess,
      builder: (groupContext, state) {
        final loadingUI = loadingWidget ?? Center(child: Loader());
        if (state is GroupLoading) {
          return loadingUI;
        }

        if (state is GroupError) {
          if (loadOnError) return loadingUI;

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
