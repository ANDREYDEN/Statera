import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/listItems/owing_list_item.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthenticationViewModel>(context);
    var groupVm = Provider.of<GroupViewModel>(context);

    return Column(
      children: [
        Row(
          children: [
            Text(
              "Code:",
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
                  Icon(Icons.copy),
                  Text(
                    groupVm.group.code.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Text('Owings'),
        Flexible(
          child: StreamBuilder<Map<Author, List<Expense>>>(
            stream: Firestore.instance
                .getOwingsForUserInGroup(authVm.user.uid, groupVm.group.id),
            builder: (context, membersSnapshot) {
              if (membersSnapshot.hasError) {
                return Text(membersSnapshot.error.toString());
              }
              if (membersSnapshot.connectionState == ConnectionState.waiting ||
                  !membersSnapshot.hasData) {
                return Text("Loading...");
              }

              var owings = membersSnapshot.data!;
              return ListView.builder(
                itemCount: owings.length,
                itemBuilder: (context, index) {
                  var payer = owings.keys.elementAt(index);
                  return OwingListItem(
                    payer: payer,
                    outstandingExpenses: owings[payer]!,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
