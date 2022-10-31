part of 'payments_cubit.dart';

abstract class PaymentsState extends Equatable {
  const PaymentsState();
}

class PaymentsLoading extends PaymentsState {
  List<Object?> get props => [];
}

class PaymentsError extends PaymentsState {
  final String error;

  const PaymentsError({required this.error});

  List<Object?> get props => [error];
}

class PaymentsLoaded extends PaymentsState {
  final List<Payment> payments;

  const PaymentsLoaded({required this.payments});

  @override
  List<Object?> get props => [payments];
}
