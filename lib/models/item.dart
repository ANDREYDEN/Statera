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

  ExpenseDecision assigneeDeicision(String uid) {
    var assignee = assignees.firstWhere(
      (element) => element.uid == uid,
      orElse: () => throw new Exception(
          "Can not find assignee with uid $uid for item $name"),
    );
    return assignee.decision;
  }
}
