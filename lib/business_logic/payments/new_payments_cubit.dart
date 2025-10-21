import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'new_payments_state.dart';

class NewPaymentsCubit extends Cubit<NewPaymentsState> {
  late final PaymentService _paymentService;
  late final ErrorService _errorService;

  StreamSubscription? _paymentsSubscription;

  NewPaymentsCubit(PaymentService paymentService, ErrorService errorService)
    : super(NewPaymentsState.loading()) {
    _paymentService = paymentService;
    _errorService = errorService;
  }

  void load({required String? groupId, required String uid}) {
    _paymentsSubscription?.cancel();
    _paymentsSubscription = _paymentService
        .paymentsStream(groupId: groupId, userId1: uid, newFor: uid)
        .map((payments) => NewPaymentsState(payments: payments))
        .listen(
          emit,
          onError: (error) {
            if (error is Exception) {
              _errorService.recordError(
                error,
                reason: 'Failed to listen to new payments stream',
              );
            }
            emit(NewPaymentsState.error(error.toString()));
          },
        );
  }
}
