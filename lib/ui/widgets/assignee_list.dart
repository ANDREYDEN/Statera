import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/states/group_state.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/loader.dart';

class AssigneeList extends StatelessWidget {
  const AssigneeList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Expense expense = Provider.of<Expense>(context);

    return Container(
      height: 50,
      child: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, groupState) {
          if (groupState is GroupLoadingState) {
            return Center(child: Loader());
          }

          if (groupState is GroupErrorState) {
            return Text(groupState.error.toString());
          }

          if (groupState is GroupLoadedState) {
            return Row(
              children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: expense.assignees.map((assignee) {
                      if (!groupState.group.userExists(assignee.uid)) return Icon(Icons.error);
                      var member = groupState.group.getUser(assignee.uid);
                      return AuthorAvatar(
                        margin: const EdgeInsets.only(right: 4),
                        author: member,
                        checked: expense.isMarkedBy(assignee.uid),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
