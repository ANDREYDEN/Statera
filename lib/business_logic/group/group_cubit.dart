import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit(this._groupService, this._expenseService) : super(GroupLoading());

  StreamSubscription? _groupSubscription;
  GroupService _groupService;
  ExpenseService _expenseService;

  // TODO: error handling
  GroupLoaded get loadedState => state as GroupLoaded;

  void load(String? groupId) {
    _groupSubscription?.cancel();
    _groupSubscription = _groupService
        .groupStream(groupId)
        .map((group) => group == null
            ? GroupError(error: 'Group does not exist')
            : GroupLoaded(group: group))
        .listen(emit);
  }

  void loadFromExpense(String? expenseId) async {
    final expense = await _expenseService.getExpense(expenseId);
    load(expense.groupId);
  }

  void removeUser(String uid) {
    final group = loadedState.group;
    if (group.members.every((member) => member.uid != uid)) return;

    group.removeUser(uid);
    if (group.members.isEmpty) {
      _groupService.deleteGroup(group.id);
    } else {
      _groupService.saveGroup(group);
    }
  }

  void updateBalance(Expense expense) async {
    final group = loadedState.group;
    group.updateBalance(expense);
    await _groupService.saveGroup(group);
  }

  void join(String? code, User user) async {
    if (code != loadedState.group.code) {
      emit(GroupError(error: 'Invalid invitation. Make sure you have copied the link correctly.'));
      return;
    }

    if (loadedState.group.userExists(user.uid)) {
      emit(GroupError(error: 'You are already a member of this group'));
      return;
    }

    emit(GroupLoading());
    await _groupService.joinGroup(code!, user);
    emit(GroupJoinSuccess());
  }

  @override
  Future<void> close() {
    _groupSubscription?.cancel();
    return super.close();
  }
}
