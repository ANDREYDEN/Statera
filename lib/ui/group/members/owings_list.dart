import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/group_qr_button.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_button.dart';
import 'package:statera/ui/group/members/owing_list_item.dart';
import 'package:statera/ui/group/members/owing_list_loading.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/section_title.dart';

class OwingsList extends StatelessWidget {
  const OwingsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SectionTitle('Your Owings'),
        ),
        RedirectDebtButton(),
        Flexible(
          child: GroupBuilder(
            loadingWidget: OwingListLoading(),
            builder: (context, group) {
              final owings = group.getOwingsForUser(authBloc.uid);

              if (owings.isEmpty) {
                return ListEmpty(
                  text: 'Start by inviting people to your group',
                  actions: [GroupQRButton()],
                );
              }

              return BlocBuilder<NewPaymentsCubit, NewPaymentsState>(
                builder: (context, newPaymentsState) {
                  if (newPaymentsState.isLoading) return OwingListLoading();

                  final mostRecentPaymentMap =
                      newPaymentsState.mostRecentPaymentMap;
                  final paymentCount = newPaymentsState.paymentCount;
                  final userOwings = owings.entries.toList();
                  userOwings.sort((a, b) {
                    final aDate = mostRecentPaymentMap[a.key.uid];
                    final bDate = mostRecentPaymentMap[b.key.uid];
                    
                    if (aDate == null && bDate != null) return 1;
                    if (aDate != null && bDate == null) return -1;
                    
                    if (aDate != null && bDate != null) {
                      final dateComparison = bDate.compareTo(aDate);
                      if (dateComparison != 0) return dateComparison;
                    }
                    
                    final debtComparison = b.value.compareTo(a.value);
                    if (debtComparison != 0) return debtComparison;
                    
                    return a.key.name.toLowerCase().compareTo(
                      b.key.name.toLowerCase(),
                    );
                  });

                  return ListView.separated(
                    itemCount: userOwings.length,
                    itemBuilder: ((context, index) {
                      var userOwing = userOwings[index];
                      return OwingListItem(
                        member: userOwing.key,
                        owing: userOwing.value,
                        newPaymentsCount: paymentCount[userOwing.key.uid] ?? 0,
                      );
                    }),
                    separatorBuilder: (context, index) => Divider(height: 10),
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
