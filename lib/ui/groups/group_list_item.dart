import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/unmarked_expenses_cubit.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/unmarked_expenses_badge.dart';

class GroupListItem extends StatelessWidget {
  final Group group;

  const GroupListItem({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(GroupPage.route + '/${this.group.id}');
      },
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: BlocProvider<UnmarkedExpensesCubit>(
              create: (context) => UnmarkedExpensesCubit(
                context.read<GroupService>(),
                groupId: this.group.id,
                uid: context.read<AuthBloc>().uid,
              ),
              child: UnmarkedExpensesBadge(
                child: Text(
                  this.group.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person),
          Text(this.group.members.length.toString()),
        ],
      ),
    );
  }
}
