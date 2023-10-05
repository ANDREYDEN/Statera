import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';

part 'debt_redirection_state.dart';

class DebtRedirectionCubit extends Cubit<DebtRedirectionState> {
  StreamSubscription<GroupState>? _groupSubscription;

  DebtRedirectionCubit() : super(DebtRedirectionLoading());

  init({required String uid, required GroupCubit groupCubit}) {
    _init(uid, groupCubit.state);

    _groupSubscription = groupCubit.stream.listen((groupState) {
      _init(uid, groupState);
    });
  }

  _init(String uid, GroupState groupState) {
    if (groupState is! GroupLoaded) return;

    final group = groupState.group;

    if (!group.supportsDebtRedirection) {
      return emit(DebtRedirectionOff());
    }

    if (!group.canRedirect(uid)) {
      return emit(DebtRedirectionImpossible());
    }

    emit(DebtRedirectionLoaded.initial(uid: uid, group: group));
  }

  void changeOwer({required String newOwerUid}) {
    if (this.state is! DebtRedirectionLoaded) return;

    final state = this.state as DebtRedirectionLoaded;

    final (newOwerDebt, newAuthorDebt, _) = state.group.estimateRedirect(
      authorUid: state.uid,
      owerUid: newOwerUid,
      receiverUid: state.receiverUid,
    );

    emit(state.copyWith(
      owerUid: newOwerUid,
      newAuthorDebt: newAuthorDebt,
      newOwerDebt: newOwerDebt,
    ));
  }

  void changeReceiver({required String newReceiverUid}) {
    if (this.state is! DebtRedirectionLoaded) return;

    final state = this.state as DebtRedirectionLoaded;

    final (newOwerDebt, newAuthorDebt, _) = state.group.estimateRedirect(
      authorUid: state.uid,
      owerUid: state.owerUid,
      receiverUid: newReceiverUid,
    );

    emit(state.copyWith(
      receiverUid: newReceiverUid,
      newAuthorDebt: newAuthorDebt,
      newOwerDebt: newOwerDebt,
    ));
  }

  void startLoading() {
    _groupSubscription?.cancel();
    emit(DebtRedirectionLoading());
  }

  @override
  Future<void> close() {
    _groupSubscription?.cancel();
    return super.close();
  }
}
