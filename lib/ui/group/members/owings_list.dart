import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/group_qr_button.dart';
import 'package:statera/ui/group/members/owing_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';

class OwingsList extends StatelessWidget {
  const OwingsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authBloc = context.read<AuthBloc>();

    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'Your Owings',
          style: Theme.of(context).textTheme.headline6,
        ),
        Flexible(
          child: GroupBuilder(
            builder: (context, group) {
              final owings = group.extendedBalance(authBloc.uid);
              return owings.isEmpty
                  ? ListEmpty(
                      text: 'Start by inviting people to your group...',
                      action: GroupQRButton(),
                    )
                  : ListView.builder(
                      itemCount: owings.length,
                      itemBuilder: (context, index) {
                        var payer = owings.keys.elementAt(index);
                        return OwingListItem(
                          member: payer,
                          owing: owings[payer]!,
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
