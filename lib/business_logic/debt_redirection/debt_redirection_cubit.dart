import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/payment_service.dart';
import 'package:statera/data/value_objects/redirect.dart';

part 'debt_redirection_state.dart';

class DebtRedirectionCubit extends Cubit<DebtRedirectionState> {
  late final PaymentService _paymentService;

  DebtRedirectionCubit(PaymentService paymentService)
      : super(DebtRedirectionLoading()) {
    _paymentService = paymentService;
  }

  init(String uid, Group group) {
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

  Future createPayments() {
    if (this.state is! DebtRedirectionLoaded) return Future.value();

    final state = this.state as DebtRedirectionLoaded;
    final payments = state.redirect.getPayments(state.group);

    emit(DebtRedirectionLoading());

    return Future.wait(
      payments.map((payment) => _paymentService.addPayment(payment)),
    );
  }
}
