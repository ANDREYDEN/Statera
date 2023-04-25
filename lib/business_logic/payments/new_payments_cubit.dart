import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'new_payments_state.dart';

class NewPaymentsCubit extends Cubit<NewPaymentsState> {
  late final PaymentService _paymentService;
  StreamSubscription? _paymentsSubscription;

  NewPaymentsCubit(PaymentService paymentService) : super(NewPaymentsLoading()) {
    _paymentService = paymentService;
  }

  void load({
    required String? groupId,
    required String uid,
  }) {
    _paymentsSubscription?.cancel();
    _paymentsSubscription = _paymentService
        .paymentsStream(groupId: groupId, userId1: uid, viewed: true)
        .map((payments) {
      payments.sort();
      return NewPaymentsLoaded(payments: payments);
    }).listen(
      emit,
      onError: (error) {
        if (error is Exception) {
          FirebaseCrashlytics.instance.recordError(
            error,
            null,
            reason: 'Payments failed to load',
          );
        }
        emit(NewPaymentsError(error: error));
      },
    );
  }
}
