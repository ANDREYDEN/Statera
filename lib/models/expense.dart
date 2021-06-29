import 'package:statera/models/assignee.dart';
import 'package:statera/models/item.dart';

class Expense {
  List<Item> items = [];
  String name;
  String author; // UID
  bool completed = false;
  String? id = "";

  Expense({required this.name, required this.author});

  List<Assignee> get assignees => items.isEmpty ? [] : items[0].assignees;

  double get total => items.fold<double>(
      0, (previousValue, item) => previousValue + item.value);

  bool isCompletedForUser(String uid) {
    return items.fold(
        true,
        (previousValue, item) =>
            previousValue &&
            item.assigneeDecision(uid) != ExpenseDecision.Undefined);
  }

  addItem(Item item) {
    item.assignees = [...this.assignees];
    items.add(item);
  }

  addAssignees(List<Assignee> assignees) {
    items.forEach((item) {
      item.assignees = [...assignees];
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
      "name": name,
      "items": items.map((item) => item.toFirestore()).toList(),
      "author": author,
      "assignees": assignees.map((assignee) => assignee.uid).toList()
    };
  }

  static Expense fromFirestore(Map<String, dynamic> data, String? id) {
    var expense = new Expense(
      author: data["author"],
      name: data["name"],
    );
    expense.id = id;
    data["items"]
        .forEach((itemData) => {expense.items.add(Item.fromFirestore(itemData))});
    return expense;
  }
}
