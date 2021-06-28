import 'package:statera/models/assignee.dart';
import 'package:statera/models/item.dart';

class Expense {
  List<Item> items = [];
  String name;
  String author; // UID
  bool completed = false;

  Expense({required this.name, required this.author});

  List<Assignee> get assignees => items[0].assignees;

  addAssignees(List<Assignee> assignees) {
    items.forEach((item) {
      item.assignees.setAll(0, assignees);
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
        if (item.assigneeDeicision(uid) == ExpenseDecision.Confirmed) {
          return previousValue + item.sharedValue;
        }
        return previousValue;
      },
    );
  }
}
