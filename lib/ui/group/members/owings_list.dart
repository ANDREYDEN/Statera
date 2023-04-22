import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/group_qr_button.dart';
import 'package:statera/ui/group/members/owing_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/section_title.dart';

class OwingsList extends StatelessWidget {
  const OwingsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();
    final paymentService = context.watch<PaymentService>();

    return Column(
      children: [
        SizedBox(height: 20),
        SectionTitle('Your Owings'),
        Flexible(
          child: GroupBuilder(
            builder: (context, group) {
              final owings = group.getOwingsForUser(authBloc.uid);
              if (owings.isEmpty) {
                return ListEmpty(
                  text: 'Start by inviting people to your group...',
                  action: GroupQRButton(),
                );
              }

              return FutureBuilder<List<String>>(
                  future: paymentService.getUidsByMostRecentPayment(
                      group, authBloc.uid),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Center(child: Loader());
                    }

                    if (snap.hasError) {
                      debugPrint(snap.error.toString());
                      debugPrintStack(stackTrace: snap.stackTrace);
                      return Center(child: Text('Error'));
                    }

                    final order = snap.data!;

                    final userOwings = owings.entries.toList();
                    userOwings.sort((a, b) {
                      final aIndex = order.indexOf(a.key.uid);
                      final bIndex = order.indexOf(b.key.uid);
                      return aIndex.compareTo(bIndex);
                    });

                    return ListView(
                      children: userOwings
                          .map((userOwing) => OwingListItem(
                                member: userOwing.key,
                                owing: userOwing.value,
                              ))
                          .toList(),
                    );
                  });
            },
          ),
        ),
      ],
    );
  }
}
