part of 'new_payments_cubit.dart';

abstract class NewPaymentsState extends Equatable {
  const NewPaymentsState();
}

class NewPaymentsLoading extends NewPaymentsState {
  List<Object?> get props => [];
}

class NewPaymentsError extends NewPaymentsState {
  final String error;

  const NewPaymentsError({required this.error});

  List<Object?> get props => [error];
}

class NewPaymentsLoaded extends NewPaymentsState {
  final List<Payment> payments;

  const NewPaymentsLoaded({required this.payments});

  int countForMember(String memberId) {
    return payments
        .where((payment) =>
            payment.receiverId == memberId || payment.payerId == memberId)
        .length;
  }

  @override
  List<Object?> get props => [payments];
}
