import 'package:statera/models/group.dart';

class GroupState {
  Group group;
  bool isLoading;
  Object? error;

  GroupState({
    required this.group,
    this.isLoading = false,
    this.error,
  });

  bool get hasError => error != null;
}

class GroupLoadingState extends GroupState {
  GroupLoadingState() : super(group: Group.fake(), isLoading: true);
}

class GroupErrorState extends GroupState {
  GroupErrorState(Object? error) : super(group: Group.fake(), error: error);
}
