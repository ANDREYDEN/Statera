import 'package:statera/models/assignee.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/item.dart';

class Expense {
  String? id = "";
  String? groupId;
  List<Item> items = [];
  String name;
  Author author; // UID
  late List<Assignee> assignees;

  Expense({
    required this.name,
    required this.author,
    required this.groupId,
  }) {
    this.assignees = [Assignee(uid: author.uid)];
  }

  double get total => items.fold<double>(
      0, (previousValue, item) => previousValue + item.value);

  bool get isReadyToPay => items.every((item) => item.completed);

  bool get isPaidFor => assignees.every((assignee) => assignee.paid);

  bool isMarkedByUser(String uid) {
    return items.fold(
        true,
        (previousValue, item) =>
            previousValue &&
            item.assigneeDecision(uid) != ProductDecision.Undefined);
  }

  int get definedAssignees => assignees.fold(
        0,
        (previousValue, assignee) =>
            previousValue + (isMarkedByUser(assignee.uid) ? 1 : 0),
      );

  addItem(Item item) {
    item.assignees =
        this.assignees.map((assignee) => AssigneeDecision(uid: assignee.uid)).toList();
    items.add(item);
  }

  addAssignees(List<Assignee> newAssignees) {
    this.assignees = [...newAssignees];
    items.forEach((item) {
      item.assignees =
          newAssignees.map((assignee) => AssigneeDecision(uid: assignee.uid)).toList();
    });
  }

  double? getItemValueForUser(String itemName, String uid) {
    Item item = items.firstWhere(
      (item) => item.name == itemName,
      orElse: () =>
          throw Exception("No expense item found with name $itemName"),
    );
    AssigneeDecision assignee = item.assignees.firstWhere(
      (element) => element.uid == uid,
      orElse: () => throw Exception(
          "Can not find assignee in expense $name with UID $uid"),
    );
    if (assignee.decision == ProductDecision.Undefined) return null;

    return item.sharedValue;
  }

  double getConfirmedTotalForUser(String uid) {
    if (!this.hasAssignee(uid)) return 0;

    return items.fold<double>(
      0,
      (previousValue, item) {
        if (item.assigneeDecision(uid) == ProductDecision.Confirmed) {
          return previousValue + item.sharedValue;
        }
        return previousValue;
      },
    );
  }

  /// Total for user for an unmarked expence.
  /// All but the [Denied] expenses count.
  double getPotentialTotalForUser(String uid) {
    if (!this.hasAssignee(uid) || this.isReadyToPay) return 0;

    return items.fold<double>(
      0,
      (previousValue, item) {
        if (item.assigneeDecision(uid) != ProductDecision.Denied) {
          return previousValue + item.sharedValue;
        }
        return previousValue;
      },
    );
  }

  bool paidBy(String uid) {
    return assignees.firstWhere((assignee) => assignee.uid == uid).paid;
  }

  void pay(String uid) {
    assignees.firstWhere((assignee) => assignee.uid == uid).paid = true;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "groupId": groupId,
      "name": name,
      "items": items.map((item) => item.toFirestore()).toList(),
      "author": author.toFirestore(),
      "assigneeIds": assignees.map((assignee) => assignee.uid).toList().toList(),
      "assignees": assignees.map((assignee) => assignee.toFirestore()).toList(),
    };
  }

  static Expense fromFirestore(Map<String, dynamic> data, String? id) {
    var expense = new Expense(
      author: Author.fromFirestore(data["author"]),
      name: data["name"],
      groupId: data["groupId"],
    );
    expense.assignees =
        data["assignees"].map<Assignee>((assigneeData) => Assignee.fromFirestore(assigneeData)).toList();
    expense.id = id;
    data["items"].forEach(
        (itemData) => {expense.items.add(Item.fromFirestore(itemData))});
    return expense;
  }

  hasAssignee(String uid) {
    return this.assignees.any((assignee) => assignee.uid == uid);
  }
}
