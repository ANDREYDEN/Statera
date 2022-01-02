import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/auth.dart';

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
            !expense.finalized,
      ),
      ExpenseStage(
        name: "Finalized",
        color: Colors.grey[400]!,
        test: (expense) => expense.finalized,
      ),
    ];
  }

  bool hasDecidedOn(Item item) => item.isMarkedBy(user.uid);

  bool hasConfirmed(Item item) =>
      hasDecidedOn(item) && item.getAssigneeParts(user.uid) > 0;

  bool hasDenied(Item item) =>
      hasDecidedOn(item) && item.getAssigneeParts(user.uid) == 0;

  int getItemParts(Item item) => item.getAssigneeParts(user.uid);

  Color getExpenseColor(Expense expense) {
    for (var stage in expenseStages) {
      if (expense.isIn(stage)) {
        return stage.color;
      }
    }
    return Colors.blue[200]!;
  }

  bool canMark(Expense expense) => expense.canBeMarkedBy(this.user.uid);

  bool canUpdate(Expense expense) => expense.canBeUpdatedBy(this.user.uid);
}
