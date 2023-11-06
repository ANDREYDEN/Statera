import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/expense.dart';

class UserExpense extends Expense {
  ExpenseStage stage;

  UserExpense({
    required super.name,
    required super.authorUid,
    super.groupId,
    this.stage = ExpenseStage.NotMarked,
  });

  UserExpense.fromExpense(
    Expense expense, {
    this.stage = ExpenseStage.NotMarked,
  }) : super(
          authorUid: expense.authorUid,
          name: expense.name,
          groupId: expense.groupId,
        ) {
    this.id = expense.id;
    this.name = expense.name;
    this.authorUid = expense.authorUid;
    this.groupId = expense.groupId;
    this.items = expense.items;
    this.assigneeUids = expense.assigneeUids;
    this.date = expense.date;
    this.finalizedDate = expense.finalizedDate;
    this.settings = expense.settings;
  }

  static UserExpense fromFirestore(Map<String, dynamic> data, String id) {
    final expense = Expense.fromFirestore(data, id);
    final stage = ExpenseStage.values[data['stage']];
    return UserExpense.fromExpense(expense, stage: stage);
  }

  static UserExpense fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return fromFirestore(data, snap.id);
  }
}
