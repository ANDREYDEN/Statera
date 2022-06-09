part of 'owing_cubit.dart';

abstract class OwingState extends Equatable {
  const OwingState();

  @override
  List<Object> get props => [];
}

class OwingLoading extends OwingState {}

class OwingLoaded extends OwingState {
  final String memberId;

  const OwingLoaded({required this.memberId});

  @override
  List<Object> get props => [memberId];
}

class OwingError extends OwingState {
  final Object error;

  OwingError({required this.error});

  @override
  List<Object> get props => [error];
}