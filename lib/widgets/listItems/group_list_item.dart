import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/group_page.dart';

class GroupListItem extends StatelessWidget {
  final Group group;

  const GroupListItem({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationViewModel authVm =
        Provider.of<AuthenticationViewModel>(context, listen: false);
    return ListTile(
      onTap: () {
        Provider.of<GroupViewModel>(context, listen: false).group = this.group;
        Navigator.of(context).pushNamed(GroupPage.route);
      },
      title: StreamBuilder<List<Expense>>(
        stream: Firestore.instance
            .listenForUnmarkedExpenses(this.group.id, authVm.user.uid),
        builder: (context, snap) {
          var unmarkedExpenses = snap.data;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                showBadge: unmarkedExpenses != null && unmarkedExpenses.isNotEmpty,
                badgeContent: Text(unmarkedExpenses?.length.toString() ?? ""),
                toAnimate: false,
                child: Text(this.group.name),
              ),
            ],
          );
        },
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
