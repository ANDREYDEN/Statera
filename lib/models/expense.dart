import 'package:statera/models/assignee.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/item.dart';

class Expense {
  String? id = "";
  String? groupId;
  List<Item> items = [];
  late String name;
  late Author author; // UID
  List<Assignee> assignees = [];

  Expense({
    required this.name,
    required this.author,
    required this.groupId,
  }) {
    this.assignees = [Assignee(uid: author.uid)];
  }

  Expense.fake() {
    this.name = "foo";
    this.author = Author(name: "foo", uid: "foo");
  }

  double get total => items.fold<double>(
      0, (previousValue, item) => previousValue + item.value);

  bool get isPaidFor => assignees
      .every((assignee) => assignee.uid == author.uid || assignee.paid);

  bool get isReadyToBePaidFor =>
      !isPaidFor && items.every((item) => item.completed);

  bool get paymentInProgress =>
      !isPaidFor && assignees.any((assignee) => assignee.paid);

  int get paidAssignees => assignees.fold(
        0,
        (previousValue, assignee) =>
            previousValue + (isPaidBy(assignee.uid) ? 1 : 0),
      );

  bool get canReceiveAssignees =>
      assignees.length == 1 || (!isPaidFor && paidAssignees == 0);

  bool isMarkedBy(String uid) {
    return items.fold(
        true,
        (previousValue, item) =>
            previousValue &&
            item.assigneeDecision(uid) != ProductDecision.Undefined);
  }

  bool isAuthoredBy(String uid) {
    return this.author.uid == uid;
  }

  int get definedAssignees => assignees.fold(
        0,
        (previousValue, assignee) =>
            previousValue + (isMarkedBy(assignee.uid) ? 1 : 0),
      );

  addItem(Item item) {
    items.add(item);
    _resetItemAssignees();
  }

  _resetItemAssignees() {
    items.forEach((item) {
      item.assignees = this.assignees.map((expenseAssignee) {
        bool assigneeExists = item.assignees
            .where((itemAssignee) => itemAssignee.uid == expenseAssignee.uid)
            .isNotEmpty;
        return AssigneeDecision(
          uid: expenseAssignee.uid,
          decision: assigneeExists
              ? item.assigneeDecision(expenseAssignee.uid)
              : ProductDecision.Undefined,
        );
      }).toList();
    });
  }

  setAssignees(List<Assignee> newAssignees) {
    this.assignees = [...newAssignees];
    _resetItemAssignees();
  }

  addAssignee(Assignee newAssignee) {
    this.assignees.add(newAssignee);
    _resetItemAssignees();
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
    if (!this.hasAssignee(uid) || this.isReadyToBePaidFor) return 0;

    return items.fold<double>(
      0,
      (previousValue, item) {
        if (item.assigneeDecision(uid) != ProductDecision.Denied) {
          return previousValue + item.getSharedValueFor(uid);
        }
        return previousValue;
      },
    );
  }

  bool isPaidBy(String uid) {
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
      "assigneeIds":
          assignees.map((assignee) => assignee.uid).toList().toList(),
      "assignees": assignees.map((assignee) => assignee.toFirestore()).toList(),
    };
  }

  static Expense fromFirestore(Map<String, dynamic> data, String? id) {
    var expense = new Expense(
      author: Author.fromFirestore(data["author"]),
      name: data["name"],
      groupId: data["groupId"],
    );
    expense.assignees = data["assignees"]
        .map<Assignee>((assigneeData) => Assignee.fromFirestore(assigneeData))
        .toList();
    expense.id = id;
    data["items"].forEach(
        (itemData) => {expense.items.add(Item.fromFirestore(itemData))});
    return expense;
  }

  hasAssignee(String uid) {
    return this.assignees.any((assignee) => assignee.uid == uid);
  }
}
