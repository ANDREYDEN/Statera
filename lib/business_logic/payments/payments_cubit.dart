import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  late final PaymentRepository _paymentRepository;
  StreamSubscription? _paymentsSubscription;

  PaymentsCubit(PaymentRepository paymentRepository)
      : super(PaymentsLoading()) {
    _paymentRepository = paymentRepository;
  }

  void load({
    required String groupId,
    required String uid,
    required String otherUid,
  }) {
    _paymentsSubscription?.cancel();
    _paymentsSubscription = _paymentRepository
        .paymentsStream(groupId: groupId, userId1: uid, userId2: otherUid)
        .map((payments) => PaymentsLoaded(payments: payments))
        .listen(
      emit,
      onError: (error) {
        if (error is Exception) {
          FirebaseCrashlytics.instance.recordError(
            error,
            null,
            reason: 'Payments failed to load',
          );
        }
        emit(PaymentsError(error: error));
      },
    );
  }
}
