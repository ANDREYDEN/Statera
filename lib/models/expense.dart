import 'package:statera/models/Author.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/item.dart';

class Expense {
  String? id = "";
  String? groupId;
  List<Item> items = [];
  String name;
  Author author; // UID
  late List<Assignee> assignees;
  bool finalized = false;

  Expense({
    required this.name,
    required this.author,
    required this.groupId,
    finalized,
  }) {
    this.assignees = [Assignee(uid: author.uid)];
    this.finalized = finalized ?? false;
  }

  double get total => items.fold<double>(
      0, (previousValue, item) => previousValue + item.value);

  bool isCompletedByUser(String uid) {
    return items.fold(
        true,
        (previousValue, item) =>
            previousValue &&
            item.assigneeDecision(uid) != ExpenseDecision.Undefined);
  }

  bool get completed => items.fold(
      true, (previousValue, item) => previousValue && item.completed);

  int get definedAssignees => assignees.fold(
        0,
        (previousValue, assignee) =>
            previousValue + (isCompletedByUser(assignee.uid) ? 1 : 0),
      );

  addItem(Item item) {
    item.assignees =
        this.assignees.map((assignee) => Assignee(uid: assignee.uid)).toList();
    items.add(item);
  }

  addAssignees(List<Assignee> newAssignees) {
    this.assignees = [...newAssignees];
    items.forEach((item) {
      item.assignees =
          newAssignees.map((assignee) => Assignee(uid: assignee.uid)).toList();
    });
  }

  double? getItemValueForUser(String itemName, String uid) {
    Item item = items.firstWhere(
      (item) => item.name == itemName,
      orElse: () =>
          throw Exception("No expense item found with name $itemName"),
    );
    Assignee assignee = item.assignees.firstWhere(
      (element) => element.uid == uid,
      orElse: () => throw Exception(
          "Can not find assignee in expense $name with UID $uid"),
    );
    if (assignee.decision == ExpenseDecision.Undefined) return null;

    return item.sharedValue;
  }

  double getTotalForUser(String uid) {
    if (!this.hasAssignee(uid)) return 0;

    return items.fold<double>(
      0,
      (previousValue, item) {
        if (item.assigneeDecision(uid) == ExpenseDecision.Confirmed) {
          return previousValue + item.sharedValue;
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
      "assignees": assignees.map((assignee) => assignee.uid).toList(),
      "finalized": finalized,
    };
  }

  static Expense fromFirestore(Map<String, dynamic> data, String? id) {
    var expense = new Expense(
      author: Author.fromFirestore(data["author"]),
      name: data["name"],
      groupId: data["groupId"],
      finalized: data["finalized"],
    );
    expense.assignees =
        data["assignees"].map<Assignee>((uid) => Assignee(uid: uid)).toList();
    expense.id = id;
    data["items"].forEach(
        (itemData) => {expense.items.add(Item.fromFirestore(itemData))});
    return expense;
  }

  hasAssignee(String uid) {
    return this.assignees.any((assignee) => assignee.uid == uid);
  }
}
