import 'package:statera/data/models/group.dart';

abstract class GroupState {
  Group group;

  GroupState({
    required this.group,
  });
}

class GroupLoadingState extends GroupState {
  GroupLoadingState() : super(group: Group.fake());
}

class GroupLoadedState extends GroupState {
  GroupLoadedState(Group group) : super(group: group);
}

class GroupErrorState extends GroupState {
  Object? error;
  GroupErrorState({this.error}) : super(group: Group.fake());
}
