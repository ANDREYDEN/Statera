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
  final bool allLoaded;
  final bool loadingMore;

  const PaymentsLoaded({
    required this.payments,
    this.allLoaded = false,
    this.loadingMore = false,
  });

  PaymentsLoaded copyWith({bool? loadingMore}) {
    return PaymentsLoaded(
      payments: payments,
      allLoaded: allLoaded,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [payments, allLoaded, loadingMore];
}
