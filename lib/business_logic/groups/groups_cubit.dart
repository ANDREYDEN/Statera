import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GroupRepository _groupRepository;
  final UserGroupRepository _userGroupRepository;
  final UserRepository _userRepository;
  StreamSubscription? _groupsSubscription;

  GroupsCubit(
    this._groupRepository,
    this._userRepository,
    this._userGroupRepository,
  ) : super(GroupsLoading());

  void load(String? userId) {
    _groupsSubscription?.cancel();
    _groupsSubscription = _userGroupRepository
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

  addGroup(Group group, String uid) async {
    final groupState = state;
    if (groupState is GroupsLoaded) {
      emit(GroupsProcessing(groups: groupState.groups));
      final user = await _userRepository.getUser(uid);
      final groupId = await _groupRepository.createGroup(group, user);
      await _groupRepository.generateInviteLink(group..id = groupId);
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
