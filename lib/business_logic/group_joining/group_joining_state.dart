part of 'group_joining_cubit.dart';

abstract class GroupJoiningState extends Equatable {
  GroupJoiningState();
}

class GroupJoiningLoading extends GroupJoiningState {
  GroupJoiningLoading() : super();
  
  @override
  List<Object?> get props => [];
}

class GroupJoiningLoaded extends GroupJoiningState {
  final Group group;

  GroupJoiningLoaded({required this.group}) : super();

  @override
  List<Object?> get props => [];
}

class GroupJoiningSuccess extends GroupJoiningState {
  GroupJoiningSuccess() : super();
  
  @override
  List<Object?> get props => [];
}

class GroupJoiningError extends GroupJoiningState {
  final Object? error;

  GroupJoiningError({required this.error}) : super();

  @override
  List<Object?> get props => [];
}
