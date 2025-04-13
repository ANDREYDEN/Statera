import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  StreamSubscription? _groupSubscription;
  final GroupRepository _groupService;
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
        .handleError(handleError)
        .listen(emit);
  }

  void loadGroup(Group group) {
    emit(GroupLoaded(group: group));
  }

  void loadFromExpense(String? expenseId) async {
    final expense = await _expenseService.getExpense(expenseId);
    load(expense.groupId);
  }

  void update(Function(Group) updater) {
    final group = loadedState.group;
    emit(GroupLoading());
    updater(group);
    _groupService.saveGroup(group);
  }

  Future<void> removeMember(String uid) async {
    final group = loadedState.group;
    if (!group.memberExists(uid)) return;
    emit(GroupLoading());

    await _expenseService.removeAssigneeFromOutstandingExpenses(uid, group.id);
    group.removeMember(uid);
    if (group.members.isEmpty) {
      await _groupService.deleteGroup(group.id);
    } else {
      await _groupService.saveGroup(group);
    }
  }

  Future<void> addMember(String? code, String uid) async {
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
      final group = await _groupService.addMember(code!, user);
      await _expenseService.addAssigneeToOutstandingExpenses(uid, group.id);
      emit(GroupJoinSuccess(group: group));
    } catch (e) {
      emit(GroupError(error: 'Error joining group: ${e.toString()}'));
    }
  }

  Future<List<Expense>> getExpensesForMember(String userUid) async {
    if (userUid.isEmpty) {
      emit(GroupError(error: 'Can not get expenses for the user'));
    }

    final groupId = loadedState.group.id;
    return await this._expenseService.getExpensesForUser(groupId!, userUid);
  }

  Future<void> generateInviteLink() async {
    final group = loadedState.group;
    emit(GroupLoading());
    await _groupService.generateInviteLink(group);
  }

  Future<void> delete() async {
    final group = loadedState.group;
    emit(GroupLoading());

    await _groupSubscription?.cancel();
    try {
      await _groupService.deleteGroup(group.id);
    } catch (error) {
      load(group.id);
      await handleError(error);
    }
  }

  Future<void> handleError(Object error) async {
    if (error is FirebaseException) {
      emit(GroupError(error: 'Permission denied'));
    } else {
      emit(GroupError(error: 'Something went wrong'));
    }
    await FirebaseCrashlytics.instance
        .recordError(error, null, reason: 'Group error');
  }

  @override
  Future<void> close() async {
    await _groupSubscription?.cancel();
    return super.close();
  }
}
