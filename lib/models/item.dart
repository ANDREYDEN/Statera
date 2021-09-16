import 'package:statera/models/assignee_decision.dart';
import 'package:uuid/uuid.dart';

class Item {
  late String id;
  late String name;
  late double value;
  int? _partition; // some items might consist of multiple equal parts that need to be treated separately
  List<AssigneeDecision> assignees = [];

  Item({required this.name, required this.value, int? partition = 1}) {
    var uuid = Uuid();
    this.id = uuid.v1();
    this._partition = partition;
  }

  Item.fake({int? partition = 1}) {
    var uuid = Uuid();
    this.id = uuid.v1();
    this.name = "foo";
    this._partition = partition;
    this.value = 145;
  }

  get confirmedCount => assignees.fold<double>(
        0,
        (previousValue, assignee) =>
            previousValue +
            (assignee.decision == ProductDecision.Confirmed ? 1 : 0),
      );

  int get partition => _partition ?? 1;
  set partition(int value) => _partition = value;

  bool get isPartitioned => partition > 1;

  double get sharedValue =>
      confirmedCount == 0 ? value : value / confirmedCount;

  double getSharedValueFor(String uid) {
    if (assigneeDecision(uid) == ProductDecision.Confirmed) {
      return sharedValue;
    }
    return value / (confirmedCount + 1);
  }

  get valueString => "\$${value.toStringAsFixed(2)}";

  bool get completed => assignees.every((assignee) => assignee.madeDecision) && undefinedParts == 0;

  int get confirmedParts => assignees
      .map((assignee) => assignee.parts)
      .reduce((acc, element) => acc + element);

  int get undefinedParts => partition - confirmedParts;

  AssigneeDecision getAssigneeById(uid) {
    return assignees.firstWhere(
      (element) => element.uid == uid,
      orElse: () => throw new Exception(
          "Can not find assignee with uid $uid for item $name"),
    );
  }

  int getAssigneeParts(String uid) {
    try {
      return getAssigneeById(uid).parts;
    } catch (e) {
      return 0;
    }
  }

  ProductDecision assigneeDecision(String uid) {
    try {
      return getAssigneeById(uid).decision;
    } catch (e) {
      return ProductDecision.Undefined;
    }
  }

  void setAssigneeDecision(String uid, int parts) {
    var assignee = getAssigneeById(uid);
    var partsIncrease = parts - assignee.parts;
    assignee.decision =
        parts <= 0 ? ProductDecision.Denied : ProductDecision.Confirmed;

    if (parts < 0 || partsIncrease > undefinedParts) return;
    assignee.parts = parts;
  }

  double getValueForAssignee(String uid) {
    return assigneeDecision(uid) == ProductDecision.Denied ? 0 : sharedValue;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "name": name,
      "value": value,
      "partition": partition,
      "assignees": assignees.map((assignee) => assignee.toFirestore()).toList(),
    };
  }

  static Item fromFirestore(Map<String, dynamic> data) {
    var uuid = Uuid();
    var item = Item(
      name: data["name"],
      value: double.parse(data["value"].toString()),
      partition: data["partition"],
    );
    item.id = data["id"] ?? uuid.v1();
    item.assignees = data["assignees"]
        .map<AssigneeDecision>(
            (assigneeData) => AssigneeDecision.fromFirestore(assigneeData))
        .toList();
    return item;
  }
}
