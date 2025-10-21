part of 'new_payments_cubit.dart';

class NewPaymentsState extends Equatable {
  final List<Payment>? payments;
  final String? error;
  final bool isLoading;

  const NewPaymentsState({required this.payments})
    : isLoading = false,
      error = null;
  const NewPaymentsState.error(this.error) : isLoading = false, payments = null;
  const NewPaymentsState.loading()
    : payments = null,
      error = null,
      isLoading = true;

  Map<String, DateTime> get mostRecentPaymentMap {
    final result = Map<String, DateTime>();
    for (var payment in payments ?? []) {
      final paymentCreatedDate = payment.timeCreated;
      if (paymentCreatedDate == null) continue;

      if (!result.containsKey(payment.receiverId) ||
          result[payment.receiverId]!.isBefore(paymentCreatedDate)) {
        result[payment.receiverId] = paymentCreatedDate;
      }

      if (!result.containsKey(payment.payerId) ||
          result[payment.payerId]!.isBefore(paymentCreatedDate)) {
        result[payment.payerId] = paymentCreatedDate;
      }
    }

    return result;
  }

  Map<String, int> get paymentCount {
    final result = Map<String, int>();
    for (var payment in payments ?? []) {
      result[payment.payerId] = (result[payment.payerId] ?? 0) + 1;
      result[payment.receiverId] = (result[payment.receiverId] ?? 0) + 1;
    }

    return result;
  }

  @override
  List<Object?> get props => [payments, isLoading, error];
}
