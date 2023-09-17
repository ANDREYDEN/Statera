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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SectionTitle('Your Owings'),
        ),
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

              return FutureBuilder<Map<String, DateTime>>(
                  future: paymentService.getMostRecentPaymentDateForMembers(
                      group, authBloc.uid),
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return Center(child: Loader());
                    }

                    if (snap.hasError) {
                      debugPrint(snap.error.toString());
                      debugPrintStack(stackTrace: snap.stackTrace);
                    }

                    final order = snap.data;

                    final userOwings = owings.entries.toList();
                    if (order != null) {
                      userOwings.sort((a, b) {
                        final aDate = order[a.key.uid];
                        final bDate = order[b.key.uid];
                        if (aDate == null && bDate == null) return 0;
                        if (aDate == null && bDate != null) return 1;
                        if (aDate != null && bDate == null) return -1;

                        return bDate!.compareTo(aDate!);
                      });
                    }

                    return ListView.separated(
                      itemCount: userOwings.length,
                      itemBuilder: ((context, index) {
                        var userOwing = userOwings[index];
                        return OwingListItem(
                          member: userOwing.key,
                          owing: userOwing.value,
                        );
                      }),
                      separatorBuilder: (context, index) => Divider(height: 10),
                    );
                  });
            },
          ),
        ),
      ],
    );
  }
}
