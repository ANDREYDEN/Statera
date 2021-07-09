import 'package:statera/models/assignee_decision.dart';

class Item {
  String name;
  double value;
  List<AssigneeDecision> assignees = [];

  Item({
    required this.name,
    required this.value,
  });

  get confirmedCount => assignees.fold<double>(
        0,
        (previousValue, assignee) =>
            previousValue +
            (assignee.decision == ProductDecision.Confirmed ? 1 : 0),
      );

  get sharedValue => confirmedCount == 0 ? value : value / confirmedCount;

  get valueString => "\$${value.toStringAsFixed(2)}";

  bool get completed => assignees.every((assignee) => assignee.madeDecision);

  AssigneeDecision getAssigneeById(uid) {
    return assignees.firstWhere(
      (element) => element.uid == uid,
      orElse: () => throw new Exception(
          "Can not find assignee with uid $uid for item $name"),
    );
  }

  ProductDecision assigneeDecision(String uid) {
    return getAssigneeById(uid).decision;
  }

  void setAssigneeDecision(String uid, ProductDecision decision) {
    var assignee = getAssigneeById(uid);
    assignee.decision = decision;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "value": value,
      "assignees": assignees.map((assignee) => assignee.toFirestore()).toList()
    };
  }

  static Item fromFirestore(Map<String, dynamic> data) {
    var item = Item(
      name: data["name"],
      value: double.parse(data["value"].toString()),
    );
    item.assignees = data["assignees"]
        .map<AssigneeDecision>((assigneeData) => AssigneeDecision.fromFirestore(assigneeData))
        .toList();
    return item;
  }
}
