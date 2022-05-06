part of 'group_cubit.dart';

abstract class GroupState extends Equatable {
  GroupState();

  @override
  List<Object?> get props => [];
}

class GroupLoading extends GroupState {}

class GroupLoaded extends GroupState {
  final Group group;

  GroupLoaded({required this.group}) : super();

  @override
  List<Object?> get props => [group];
}

class GroupJoinSuccess extends GroupState {}

class GroupError extends GroupState {
  final Object? error;

  GroupError({required this.error}) : super();

  @override
  List<Object?> get props => [error];
}
