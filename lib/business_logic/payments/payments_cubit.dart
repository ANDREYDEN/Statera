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
  String? _groupId;
  late String _uid;
  late String _otherUid;
  static const int paymentsPerPage = 20;

  PaymentsCubit(PaymentService paymentService, ErrorService errorService)
    : super(PaymentsLoading()) {
    _paymentService = paymentService;
    _errorService = errorService;
  }

  void load({
    String? groupId,
    required String uid,
    required String otherUid,
    int numberOfPayments = paymentsPerPage,
  }) {
    _groupId = groupId;
    _uid = uid;
    _otherUid = otherUid;

    _paymentsSubscription?.cancel();
    _paymentsSubscription = _paymentService
        .paymentsStream(
          groupId: groupId,
          userId1: uid,
          userId2: otherUid,
          limit: numberOfPayments,
        )
        .map(
          (payments) => PaymentsLoaded(
            payments: payments,
            allLoaded: payments.length < numberOfPayments,
          ),
        )
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

  void loadMore() {
    final currentState = state;
    if (currentState is! PaymentsLoaded) return;
    if (currentState.allLoaded || currentState.loadingMore) return;

    emit(currentState.copyWith(loadingMore: true));
    load(
      groupId: _groupId,
      uid: _uid,
      otherUid: _otherUid,
      numberOfPayments: currentState.payments.length + paymentsPerPage,
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
