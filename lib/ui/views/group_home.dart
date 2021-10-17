import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/states/group_state.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/widgets/dialogs/ok_cancel_dialog.dart';
import 'package:statera/ui/widgets/listItems/owing_list_item.dart';

class GroupHome extends StatelessWidget {
  const GroupHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthenticationViewModel>(context);
    var groupState = Provider.of<GroupState>(context);

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
                    text: groupState.group.code.toString(),
                  );
                  await Clipboard.setData(data);
                },
                child: Row(
                  children: [
                    Text(
                      groupState.group.code.toString(),
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
                .getOwingsForUserInGroup(authVm.user.uid, groupState.group.id),
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
              await authVm.leaveGroup(groupState.group);
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
