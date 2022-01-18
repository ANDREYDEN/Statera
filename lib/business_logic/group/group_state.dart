part of 'group_cubit.dart';

abstract class GroupState {
  GroupState();
}

class GroupLoading extends GroupState {
  GroupLoading() : super();
}

class GroupLoaded extends GroupState {
  Group group;

  GroupLoaded({required this.group}) : super();
}

class GroupError extends GroupState {
  Object? error;

  GroupError({required this.error}) : super();
}
