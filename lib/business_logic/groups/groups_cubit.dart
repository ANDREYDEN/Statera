import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/group_service.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  GroupsCubit() : super(GroupsLoading());

  StreamSubscription? _groupsSubscription;

  void load(String? userId) {
    _groupsSubscription?.cancel();
    _groupsSubscription = GroupService.instance
        .userGroupsStream(userId)
        .map((groups) => GroupsLoaded(groups: groups))
        .listen(
      emit,
      onError: (error) {
        emit(GroupsError(error: error));
      },
    );
  }

  updateGroup(Group group) async {
    if (state is GroupsLoaded) {
      emit(GroupsProcessing(groups: (state as GroupsLoaded).groups));
      await GroupService.instance.saveGroup(group);
    }
  }

  addGroup(Group group, User creator) async {
    if (state is GroupsLoaded) {
      emit(GroupsProcessing(groups: (state as GroupsLoaded).groups));
      await GroupService.instance.createGroup(group, creator);
    }
  }

  joinGroup(String groupCode, User newMember) async {
    if (state is GroupsLoaded) {
      emit(GroupsProcessing(groups: (state as GroupsLoaded).groups));
      await GroupService.instance.joinGroup(groupCode, newMember);
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
