import 'package:statera/models/assignee.dart';

class Item {
  String name;
  double value;
  List<Assignee> assignees = [];

  Item({
    required this.name,
    required this.value,
  });

  get confirmedCount => assignees.fold<double>(
        0,
        (previousValue, assignee) =>
            previousValue +
            (assignee.decision == ExpenseDecision.Confirmed ? 1 : 0),
      );

  get sharedValue => value / confirmedCount;

  get valueString => "\$${value.toStringAsFixed(2)}";

  Assignee getAssigneeById(uid) {
    return assignees.firstWhere(
      (element) => element.uid == uid,
      orElse: () => throw new Exception(
          "Can not find assignee with uid $uid for item $name"),
    );
  }

  ExpenseDecision assigneeDecision(String uid) {
    return getAssigneeById(uid).decision;
  }

  void setAssigneeDecision(String uid, ExpenseDecision decision) {
    var assignee = getAssigneeById(uid);
    assignee.decision = decision;
  }
}
