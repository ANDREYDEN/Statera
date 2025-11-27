part of 'groups_cubit.dart';

class GroupsState extends Equatable {
  final List<UserGroup>? groups;
  final String? error;
  final bool isLoading;
  final bool isProcessing;

  const GroupsState({required this.groups})
    : isLoading = false,
      isProcessing = false,
      error = null;

  const GroupsState.error(this.error)
    : isLoading = false,
      isProcessing = false,
      groups = null;

  const GroupsState.loading()
    : groups = null,
      error = null,
      isProcessing = false,
      isLoading = true;

  const GroupsState.processing({required this.groups})
    : error = null,
      isProcessing = true,
      isLoading = false;

  @override
  List<Object?> get props => [groups, error, isLoading, isProcessing];
}
