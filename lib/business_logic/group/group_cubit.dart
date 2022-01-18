import 'dart:async';

import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit() : super(GroupLoading());

  StreamSubscription? _groupSubscription;

  // TODO: error handling
  GroupLoaded get loadedState => state as GroupLoaded;

  void load(String? groupId) {
    _groupSubscription?.cancel();
    _groupSubscription = GroupService.instance
        .groupStream(groupId)
        .map((group) => group == null
            ? GroupError(error: 'Group does not exist')
            : GroupLoaded(group: group))
        .listen(emit);
  }

  loadFromExpense(String? expenseId) async {
    final expense = await ExpenseService.instance.getExpense(expenseId);
    load(expense.groupId);
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

  @override
  Future<void> close() {
    _groupSubscription?.cancel();
    return super.close();
  }
}
