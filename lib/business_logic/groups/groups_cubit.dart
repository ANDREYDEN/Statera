import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GroupRepository _groupRepository;
  final UserGroupRepository _userGroupRepository;
  final UserRepository _userRepository;
  StreamSubscription? _groupsSubscription;
  final ErrorService _errorService;

  GroupsCubit(
    this._groupRepository,
    this._userRepository,
    this._userGroupRepository,
    this._errorService,
  ) : super(GroupsState.loading());

  void load(String userId) {
    _groupsSubscription?.cancel();

    _groupsSubscription = _userGroupRepository
        .userGroupsStream(userId)
        .map((groups) => GroupsState(groups: groups))
        .listen(
          emit,
          onError: (error) {
            if (error is Exception) {
              _errorService.recordError(error, reason: 'Groups failed to load');
            }
            emit(GroupsState.error(error));
          },
        );
  }

  addGroup(Group group, String uid) async {
    emit(GroupsState.processing(groups: state.groups));
    final user = await _userRepository.getUser(uid);
    group.addMember(user);
    final groupId = await _groupRepository.createGroup(group);
    await _groupRepository.generateInviteLink(group..id = groupId);
  }

  Future<void> update(String uid, UserGroup targetGroup) async {
    emit(GroupsState.processing(groups: state.groups));
    await _userGroupRepository.saveUserGroup(uid, targetGroup);
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
