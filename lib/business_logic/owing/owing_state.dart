part of 'owing_cubit.dart';

abstract class OwingState extends Equatable {
  const OwingState();

  @override
  List<Object> get props => [];
}

class OwingNone extends OwingState {}

class OwingSelected extends OwingState {
  final String memberId;

  const OwingSelected({required this.memberId});

  @override
  List<Object> get props => [memberId];
}
