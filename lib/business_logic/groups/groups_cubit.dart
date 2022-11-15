import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GroupService _groupService;
  final UserRepository _userRepository;
  StreamSubscription? _groupsSubscription;

  GroupsCubit(
    this._groupService,
    this._userRepository,
  ) : super(GroupsLoading());

  void load(String? userId) {
    _groupsSubscription?.cancel();
    _groupsSubscription = _groupService
        .userGroupsStream(userId)
        .map((groups) => GroupsLoaded(groups: groups))
        .listen(
      emit,
      onError: (error) {
        if (error is Exception) {
          FirebaseCrashlytics.instance.recordError(
            error,
            null,
            reason: 'Groups failed to load',
          );
        }
        emit(GroupsError(error: error));
      },
    );
  }

  updateGroup(Group group) async {
    if (state is GroupsLoaded) {
      emit(GroupsProcessing(groups: (state as GroupsLoaded).groups));
      await _groupService.saveGroup(group);
    }
  }

  addGroup(Group group, String uid) async {
    final groupState = state;
    if (groupState is GroupsLoaded) {
      emit(GroupsProcessing(groups: groupState.groups));
      final user = await _userRepository.getUser(uid);
      final groupId = await _groupService.createGroup(group, user);
      await _groupService.generateInviteLink(group..id = groupId);
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
