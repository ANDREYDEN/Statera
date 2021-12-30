import 'dart:async';

import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/states/group_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit() : super(GroupLoadingState());

  StreamSubscription? _groupSubscription;

  // TODO: error handling
  GroupLoadedState get loadedState => state as GroupLoadedState;

  load(String? groupId) {
    _groupSubscription?.cancel();
    _groupSubscription = GroupService.instance
        .groupStream(groupId)
        .map((group) => group == null
            ? GroupErrorState(error: 'Group does not exist')
            : GroupLoadedState(group: group))
        .listen(emit);
  }

  loadFromExpense(String? expenseId) async {
    final expense = await ExpenseService.instance.getExpense(expenseId);
    load(expense.groupId);
  }

  updateName(String newName) {
    final group = loadedState.group;
    group.name = newName;
    GroupService.instance.saveGroup(group);
  }

  removeUser(String uid) {
    final group = loadedState.group;
    if (group.members.every((member) => member.uid != uid)) return;

    group.removeUser(uid);
    if (group.members.isEmpty) {
      GroupService.instance.deleteGroup(group.id);
    } else {
      GroupService.instance.saveGroup(group);
    }
  }

  Future<String> addExpense(Expense expense) {
    return GroupService.instance.addExpense(expense, loadedState.group);
  }

  updateBalance(Expense expense) async {
    final group = loadedState.group;
    group.updateBalance(expense);
    await GroupService.instance.saveGroup(group);
  }
}
