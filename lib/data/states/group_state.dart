import 'package:statera/data/models/group.dart';

abstract class GroupState {
  GroupState();
}

class GroupLoadingState extends GroupState {
  GroupLoadingState() : super();
}

class GroupLoadedState extends GroupState {
  Group group;

  GroupLoadedState({required this.group}) : super();
}

class GroupErrorState extends GroupState {
  Object? error;
  GroupErrorState({this.error}) : super();
}
