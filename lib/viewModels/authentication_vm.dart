import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/services/firestore.dart';

class AuthenticationViewModel {
  User? _user;

  AuthenticationViewModel() {
    this._user = Auth.instance.currentUser;
    Auth.instance.currentUserStream().listen((user) {
      this._user = user;
    });
  }

  User get user {
    if (_user == null)
      throw new Exception('Trying to get user when not signed in.');
    return _user!;
  }

  List<ExpenseStage> get expenseStages {
    return [
      ExpenseStage(
        name: "Not Marked",
        color: Colors.red[200]!,
        test: (expense) =>
            expense.hasAssignee(user.uid) && !expense.isMarkedBy(user.uid),
      ),
      ExpenseStage(
        name: "Pending",
        color: Colors.yellow[300]!,
        test: (expense) =>
            (expense.isMarkedBy(user.uid) || !expense.hasAssignee(user.uid)) &&
            !expense.completed,
      ),
      ExpenseStage(
        name: "Completed",
        color: Colors.grey[400]!,
        test: (expense) => expense.completed,
      ),
    ];
  }

  bool hasDecidedOn(Item item) => item.isMarkedBy(user.uid);

  bool hasConfirmed(Item item) =>
      hasDecidedOn(item) && item.getAssigneeParts(user.uid) > 0;

  bool hasDenied(Item item) =>
      hasDecidedOn(item) && item.getAssigneeParts(user.uid) == 0;

  int getItemParts(Item item) => item.getAssigneeParts(user.uid);

  Future<void> createGroup(Group newGroup) async {
    newGroup.generateCode();
    newGroup.addUser(user);
    await Firestore.instance.groupsCollection.add(newGroup.toFirestore());
  }

  Future<void> joinGroup(String groupCode) async {
    var group = await Firestore.instance.getGroup(groupCode);
    if (group.members.any((member) => member.uid == user.uid)) return;

    group.addUser(user);
    await Firestore.instance.groupsCollection
        .doc(group.id)
        .update(group.toFirestore());

    await Firestore.instance.addUserToOutstandingExpenses(user, group.id);
  }

  Future<void> leaveGroup(Group group) async {
    if (group.members.every((member) => member.uid != user.uid)) return;

    group.removeUser(user);
    if (group.members.isEmpty) {
      return Firestore.instance.deleteGroup(group.id);
    }

    return Firestore.instance.saveGroup(group);
  }

  bool canMark(Expense expense) => expense.canBeMarkedBy(this.user.uid);

  bool canUpdate(Expense expense) => expense.canBeUpdatedBy(this.user.uid);
}
