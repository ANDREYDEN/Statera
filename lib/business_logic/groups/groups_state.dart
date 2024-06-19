part of 'groups_cubit.dart';

abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object> get props => [];
}

/// Before the groups were first loaded
class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<UserGroup> groups;

  const GroupsLoaded({required this.groups});

  @override
  List<Object> get props => [groups];
}

/// After the groups were loaded; whenever the list is changing (creates, updates)
class GroupsProcessing extends GroupsLoaded {
  GroupsProcessing({required List<UserGroup> groups}) : super(groups: groups);
}

class GroupsError extends GroupsState {
  final Object error;

  GroupsError({required this.error});

  @override
  List<Object> get props => [error];
}