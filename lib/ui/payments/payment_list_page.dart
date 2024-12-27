import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/members/owing_builder.dart';
import 'package:statera/ui/payments/payment_list.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class PaymentListPage extends StatelessWidget {
  static const String name = 'Payments';

  const PaymentListPage({Key? key}) : super(key: key);

  static Widget init(String? groupId, String? memberId) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GroupCubit>(
          create: (context) => GroupCubit(
            context.read<GroupRepository>(),
            context.read<ExpenseService>(),
            context.read<UserRepository>(),
          )..load(groupId),
        ),
        BlocProvider<OwingCubit>(
          create: (context) => OwingCubit()..select(memberId ?? ''),
        ),
      ],
      child: PaymentListPage(),
    );
  }

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
