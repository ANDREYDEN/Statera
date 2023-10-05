import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_arrow.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/section_title.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class RedirectDebtVisual extends StatelessWidget {
  final bool isAfter;

  const RedirectDebtVisual({super.key, this.isAfter = false});

  Future<void> _handleOwerTap(
      BuildContext context, DebtRedirectionLoaded loadedState) async {
    final groupCubit = context.read<GroupCubit>();
    final debtRedirectionCubit = context.read<DebtRedirectionCubit>();

    final newOwerUid = await showDialog(
      context: context,
      builder: (_) => BlocProvider<GroupCubit>.value(
        value: groupCubit,
        child: MemberSelectDialog(
          value: [loadedState.owerUid],
          title: 'Select ower',
          singleSelection: true,
          excludeMe: true,
          memberUids: loadedState.owerUids,
        ),
      ),
    );

    if (newOwerUid != null) {
      debtRedirectionCubit.changeOwer(
        newOwerUid: newOwerUid,
      );
    }
  }

  Future<void> _handleReceiverTap(
      BuildContext context, DebtRedirectionLoaded loadedState) async {
    final groupCubit = context.read<GroupCubit>();
    final debtRedirectionCubit = context.read<DebtRedirectionCubit>();

    final newReceiverUid = await showDialog(
      context: context,
      builder: (_) => BlocProvider<GroupCubit>.value(
        value: groupCubit,
        child: MemberSelectDialog(
          value: [loadedState.receiverUid],
          title: 'Select receiver',
          singleSelection: true,
          excludeMe: true,
          memberUids: loadedState.receiverUids,
        ),
      ),
    );

    if (newReceiverUid != null) {
      debtRedirectionCubit.changeReceiver(
        newReceiverUid: newReceiverUid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtRedirectionCubit, DebtRedirectionState>(
        builder: (context, state) {
      if (state is! DebtRedirectionLoaded && state is! DebtRedirectionLoading) {
        return SizedBox.shrink();
      }

      final isLoading = state is DebtRedirectionLoading;

      var loadedState = DebtRedirectionLoaded.fake();
      if (state is DebtRedirectionLoaded) {
        loadedState = state;
      }

      return Column(
        children: [
          SizedBox(height: 20),
          SectionTitle(
            isAfter ? 'After' : 'Before',
            alignment: Alignment.centerLeft,
          ),
          Row(
            children: [
              UserAvatar(
                author: loadedState.ower,
                dimension: 75,
                withName: true,
                namePosition: NamePosition.bottom,
                onTap: () => _handleOwerTap(context, loadedState),
                loading: isLoading,
              ),
              Expanded(
                child: RedirectArrow(
                  value:
                      isAfter ? loadedState.newOwerDebt : loadedState.owerDebt,
                  color: Colors.green,
                  loading: isLoading,
                ),
              ),
              UserAvatar(
                author: loadedState.author,
                dimension: 75,
                withName: true,
                namePosition: NamePosition.bottom,
                loading: isLoading,
              ),
              Expanded(
                child: RedirectArrow(
                  value: isAfter
                      ? loadedState.newAuthorDebt
                      : loadedState.authorDebt,
                  color: Colors.red,
                  loading: isLoading,
                ),
              ),
              UserAvatar(
                author: loadedState.receiver,
                dimension: 75,
                withName: true,
                namePosition: NamePosition.bottom,
                onTap: () => _handleReceiverTap(context, loadedState),
                loading: isLoading,
              ),
            ],
          ),
        ],
      );
    });
  }
}
