import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';

part 'debt_redirection_state.dart';

class DebtRedirectionCubit extends Cubit<DebtRedirectionState> {
  DebtRedirectionCubit() : super(DebtRedirectionLoading());

  init({required String uid, required Group group}) {
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
    emit(DebtRedirectionLoading());
  }
}
