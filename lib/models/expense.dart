import 'package:statera/models/assignee.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/group.dart';
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

  bool get canReceiveAssignees => assignees.length == 1 || paidAssignees == 0;

  int get paidAssignees => assignees.fold(
        0,
        (previousValue, assignee) =>
            previousValue + (isPaidBy(assignee.uid) ? 1 : 0),
      );

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

  bool isPaidBy(String uid) {
    return assignees.firstWhere((assignee) => assignee.uid == uid).paid;
  }

  void pay(String uid) {
    assignees.firstWhere((assignee) => assignee.uid == uid).paid = true;
  }

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

  addAssignee(Assignee newAssignee) {
    this.items.forEach((item) {
      item.assignees.add(AssigneeDecision(
        uid: newAssignee.uid,
      ));
    });
    this.assignees.add(newAssignee);
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

  double? getItemValueForAssignee(String itemName, String uid) {
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

    return item.getValueForAssignee(uid);
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
          .toList()
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
