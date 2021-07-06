import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/Author.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/views/expense_list.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationViewModel _authVm = Provider.of<AuthenticationViewModel>(context);
    return Column(
      children: [
        Text('Owings'),
        Flexible(
          child: StreamBuilder<Map<Author, double>>(
              stream: Firestore.instance.getOwingsForUser(_authVm.user.uid),
              builder: (context, membersSnapshot) {
                if (membersSnapshot.hasError) {
                  return Text(membersSnapshot.error.toString());
                }
                if (membersSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    !membersSnapshot.hasData) {
                  return Text("Loading...");
                }

                var owings = membersSnapshot.data!;
                return ListView.builder(
                  itemCount: owings.length,
                  itemBuilder: (context, index) {
                    var payer = owings.keys.elementAt(index);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(payer.name),
                        Text(owings[payer].toString())
                      ],
                    );
                  },
                );
              }),
        ),
      ],
    );
  }
}
