import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/dialogs/ok_cancel_dialog.dart';
import 'package:statera/widgets/listItems/owing_list_item.dart';

class GroupHome extends StatelessWidget {
  const GroupHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthenticationViewModel>(context);
    var groupVm = Provider.of<GroupViewModel>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Invite people with the code:",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              TextButton(
                onPressed: () async {
                  ClipboardData data = ClipboardData(
                    text: groupVm.group.code.toString(),
                  );
                  await Clipboard.setData(data);
                },
                child: Row(
                  children: [
                    Text(
                      groupVm.group.code.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.copy),
                  ],
                ),
              )
            ],
          ),
        ),
        Divider(thickness: 1),
        SizedBox(height: 20),
        Text(
          'Your Owings',
          style: Theme.of(context).textTheme.headline6,
        ),
        Flexible(
          child: StreamProvider<Map<Author, double>>(
            initialData: {},
            create: (context) => Firestore.instance
                .getOwingsForUserInGroup(authVm.user.uid, groupVm.group.id),
            child: Consumer<Map<Author, double>>(
              builder: (_, owings, __) => ListView.builder(
                itemCount: owings.length,
                itemBuilder: (context, index) {
                  var payer = owings.keys.elementAt(index);
                  return OwingListItem(
                    payer: payer,
                    owing: owings[payer]!,
                  );
                },
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            var decision = await showDialog<bool>(
              context: context,
              builder: (context) => OKCancelDialog(
                text: "Are you sure you want to leave the group?",
              ),
            );
            if (decision!) {
              await authVm.leaveGroup(groupVm.group);
              Navigator.pop(context);
            }
          },
          child: Text(
            "Leave group",
            style: TextStyle(
              color: Theme.of(context).errorColor,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }
}
