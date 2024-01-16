import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/members/owing_builder.dart';
import 'package:statera/ui/payments/payment_list.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class PaymentListPage extends StatelessWidget {
  static const String route = '/payments';

  const PaymentListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final owingCubit = context.watch<OwingCubit>();

    return OwingBuilder(
      builder: (context, otherMemberId) {
        return PageScaffold(
          titleBuilder: (context, titleWidgetBuilder) => GroupBuilder(
            loadingWidget: Text('... Payments'),
            builder: (context, group) {
              var otherMember = group.getMember(otherMemberId);
              return titleWidgetBuilder('${otherMember.name} Payments');
            },
            errorBuilder: (context, error) => titleWidgetBuilder('Error'),
          ),
          onPop: (didPop) {
            if (!didPop) return;
            owingCubit.deselect();
          },
          child: PaymentList(),
        );
      },
    );
  }
}
