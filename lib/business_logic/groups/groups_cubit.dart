import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  late final GroupService _groupService;
  late final DynamicLinkRepository _dynamicLinkRepository;
  StreamSubscription? _groupsSubscription;

  GroupsCubit(
    GroupService groupService,
    DynamicLinkRepository dynamicLinkRepository,
  ) : super(GroupsLoading()) {
    _groupService = groupService;
    _dynamicLinkRepository = dynamicLinkRepository;
  }

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

  addGroup(Group group, User creator) async {
    final groupState = state;
    if (groupState is GroupsLoaded) {
      emit(GroupsProcessing(groups: groupState.groups));
      final groupId = await _groupService.createGroup(group, creator);
      final link = await _dynamicLinkRepository.generateDynamicLink(
        path: 'groups/$groupId/join/${group.code}',
        socialTitle: 'Join "${group.name}"',
        socialDescription: 'This is an invite to join a new group in Statera',
      );
      group.inviteLink = link;
      await _groupService.saveGroup(group);
    }
  }

  joinGroup(String groupCode, User newMember) async {
    if (state is GroupsLoaded) {
      emit(GroupsProcessing(groups: (state as GroupsLoaded).groups));
      await _groupService.joinGroup(groupCode, newMember);
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
