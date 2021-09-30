import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/group.dart';
import 'package:statera/models/item.dart';

class ExpenseStage {
  String name;
  Color color;
  bool Function(Expense) test;

  ExpenseStage({
    required this.name,
    required this.color,
    required this.test,
  });
}

class Expense {
  String? id = "";
  String? groupId;
  List<Item> items = [];
  List<Assignee> assignees = [];
  late String name;
  late Author author; // UID
  DateTime? date;

  Expense({
    required this.name,
    required this.author,
    required this.groupId,
  }) {
    this.assignees = [Assignee(uid: author.uid)];
    this.date = DateTime.now();
  }

  Expense.fake() {
    this.name = "foo";
    this.author = Author(name: "foo", uid: "foo");
    this.date = DateTime.now();
  }

  String? get formattedDate =>
      this.date == null ? null : DateFormat('d MMM, yyyy').format(this.date!);

  bool wasEarlierThan(Expense other) {
    if (this.date == null) return true;
    if (other.date == null) return false;

    return this.date!.compareTo(other.date!) < 0;
  }

  double get total => items.fold<double>(
      0, (previousValue, item) => previousValue + item.value);

  bool isIn(ExpenseStage stage) => stage.test(this);

  bool get completed =>
      items.isNotEmpty && items.every((item) => item.completed);

  bool get canReceiveAssignees =>
      (assignees.length == 1 && this.isAuthoredBy(assignees.first.uid)) ||
      !completed;

  bool isMarkedBy(String uid) => items.every((item) => item.isMarkedBy(uid));

  bool isAuthoredBy(String uid) => this.author.uid == uid;

  bool canBeUpdatedBy(String uid) => this.isAuthoredBy(uid) && !this.completed;

  bool canBeMarkedBy(String uid) =>
      !this.completed && this.assignees.any((assignee) => assignee.uid == uid);

  int get definedAssignees => assignees.fold(
        0,
        (previousValue, assignee) =>
            previousValue + (isMarkedBy(assignee.uid) ? 1 : 0),
      );

  addItem(Item newItem) {
    newItem.assignees = this
        .assignees
        .map((assignee) => AssigneeDecision(uid: assignee.uid))
        .toList();
    this.items.add(newItem);
  }

  void updateItem(Item newItem) {
    var itemIdx = this.items.indexWhere((item) => item.id == newItem.id);
    this.items[itemIdx] = newItem;
  }

  get hasNoItems => this.items.isEmpty;

  addAssignee(Assignee newAssignee) {
    this.items.forEach((item) {
      item.assignees.add(AssigneeDecision(
        uid: newAssignee.uid,
      ));
    });
    this.assignees.add(newAssignee);
  }

  void updateAssignees(List<String> selectedUids) {
    if (selectedUids.isEmpty)
      throw new Exception('Assignee list can not be empty');

    this.assignees = selectedUids.map((uid) => Assignee(uid: uid)).toList();

    this.items.forEach((item) {
      item.assignees = selectedUids.map((uid) {
        try {
          return item.assignees.firstWhere((assignee) => assignee.uid == uid);
        } catch (e) {
          return AssigneeDecision(uid: uid);
        }
      }).toList();
    });
  }

  assignGroup(Group group) {
    this.groupId = group.id;
    var assignees =
        group.members.map((member) => Assignee(uid: member.uid)).toList();
    this.assignees = assignees;
    this.items.forEach((item) {
      item.assignees = group.members
          .map((member) => AssigneeDecision(uid: member.uid))
          .toList();
    });
  }

  double getConfirmedTotalForUser(String uid) {
    if (!this.hasAssignee(uid)) return 0;

    return items.fold<double>(
      0,
      (previousValue, item) => previousValue + item.getSharedValueFor(uid),
    );
  }

  bool hasAssignee(String uid) {
    return this.assignees.any((assignee) => assignee.uid == uid);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "groupId": groupId,
      "name": name,
      "items": items.map((item) => item.toFirestore()).toList(),
      "author": author.toFirestore(),
      "assigneeIds":
          assignees.map((assignee) => assignee.uid).toList().toList(),
      "assignees": assignees.map((assignee) => assignee.toFirestore()).toList(),
      "unmarkedAssigneeIds": assignees
          .where((assignee) => !isMarkedBy(assignee.uid))
          .map((assignee) => assignee.uid)
          .toList(),
      "date": date
    };
  }

  static Expense fromFirestore(Map<String, dynamic> data, String? id) {
    var expense = new Expense(
      author: Author.fromFirestore(data["author"]),
      name: data["name"],
      groupId: data["groupId"],
    );
    expense.id = id;
    expense.date = data["date"] == null
        ? null
        : DateTime.parse(data["date"].toDate().toString());
    expense.assignees = data["assignees"]
        .map<Assignee>((assigneeData) => Assignee.fromFirestore(assigneeData))
        .toList();
    data["items"].forEach(
        (itemData) => {expense.items.add(Item.fromFirestore(itemData))});
    return expense;
  }
}
