import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  late final PaymentService _paymentService;
  StreamSubscription? _paymentsSubscription;
  late final ErrorService _errorService;

  PaymentsCubit(PaymentService paymentService, ErrorService errorService)
    : super(PaymentsLoading()) {
    _paymentService = paymentService;
    _errorService = errorService;
  }

  void load({
    required String groupId,
    required String uid,
    required String otherUid,
  }) {
    _paymentsSubscription?.cancel();
    _paymentsSubscription = _paymentService
        .paymentsStream(groupId: groupId, userId1: uid, userId2: otherUid)
        .map((payments) {
          payments.sort();
          return PaymentsLoaded(payments: payments);
        })
        .listen(
          emit,
          onError: (error) {
            if (error is Exception) {
              _errorService.recordError(
                error,
                reason: 'Payments failed to load',
              );
            }
            emit(PaymentsError(error: error));
          },
        );
  }

  Future<void> view(String uid) async {
    final currentState = state;
    if (!(currentState is PaymentsLoaded)) return;

    try {
      return await _paymentService.view(currentState.payments, uid);
    } catch (error) {
      await _errorService.recordError(
        error,
        reason: 'Failed to mark payments as viewed',
      );
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _paymentsSubscription?.cancel();
    return super.close();
  }
}
