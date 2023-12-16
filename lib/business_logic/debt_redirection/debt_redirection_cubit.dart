import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/value_objects/redirect.dart';

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

    final redirect = state.group.estimateRedirect(
      authorUid: state.authorUid,
      owerUid: newOwerUid,
      receiverUid: state.receiverUid,
    );

    emit(state.copyWith(redirect: redirect));
  }

  void changeReceiver({required String newReceiverUid}) {
    if (this.state is! DebtRedirectionLoaded) return;

    final state = this.state as DebtRedirectionLoaded;

    final redirect = state.group.estimateRedirect(
      authorUid: state.authorUid,
      owerUid: state.owerUid,
      receiverUid: newReceiverUid,
    );

    emit(state.copyWith(redirect: redirect));
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
