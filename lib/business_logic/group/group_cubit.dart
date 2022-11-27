import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  StreamSubscription? _groupSubscription;
  final GroupService _groupService;
  final ExpenseService _expenseService;
  final UserRepository _userRepository;

  GroupCubit(
    this._groupService,
    this._expenseService,
    this._userRepository,
  ) : super(GroupLoading());

  // TODO: error handling
  GroupLoaded get loadedState => state as GroupLoaded;

  void load(String? groupId) {
    _groupSubscription?.cancel();
    _groupSubscription = _groupService
        .groupStream(groupId)
        .map((group) => group == null
            ? GroupError(error: 'Group does not exist')
            : GroupLoaded(group: group))
        .handleError((e) {
      if (e is FirebaseException) {
        emit(GroupError(error: 'Permission denied'));
      } else {
        emit(GroupError(error: 'Something went wrong'));
      }
    }).listen(emit);
  }

  void loadGroup(Group group) {
    emit(GroupLoaded(group: group));
  }

  void loadFromExpense(String? expenseId) async {
    final expense = await _expenseService.getExpense(expenseId);
    load(expense.groupId);
  }

  void removeMember(String uid) {
    final group = loadedState.group;
    emit(GroupLoading());
    if (group.members.every((member) => member.uid != uid)) return;

    group.removeMember(uid);
    if (group.members.isEmpty) {
      _groupService.deleteGroup(group.id);
    } else {
      _groupService.saveGroup(group);
    }
  }

  void update(Function(Group) updater) {
    final group = loadedState.group;
    emit(GroupLoading());
    updater(group);
    _groupService.saveGroup(group);
  }

  Future<void> join(String? code, String uid) async {
    if (code != loadedState.group.code) {
      emit(GroupError(
          error:
              'Invalid invitation. Make sure you have copied the link correctly.'));
      return;
    }

    if (loadedState.group.memberExists(uid)) {
      emit(GroupError(error: 'You are already a member of this group'));
      return;
    }

    emit(GroupLoading());
    try {
      final user = await _userRepository.getUser(uid);
      final group = await _groupService.joinGroup(code!, user);
      await _expenseService.addUserToOutstandingExpenses(uid, group.id);
      emit(GroupJoinSuccess(group: group));
    } catch (e) {
      emit(GroupError(error: 'Error joining group: ${e.toString()}'));
    }
  }

  void generateInviteLink() async {
    final group = loadedState.group;
    emit(GroupLoading());
    await _groupService.generateInviteLink(group);
  }

  void delete() {
    final group = loadedState.group;
    emit(GroupLoading());

    _groupService.deleteGroup(group.id);
  }

  @override
  Future<void> close() {
    _groupSubscription?.cancel();
    return super.close();
  }
}
