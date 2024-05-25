import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/gas_item.dart';
import 'package:statera/data/models/simple_item.dart';
import 'package:uuid/uuid.dart';

import 'assignee_decision.dart';

abstract class Item {
  late String id;
  late String name;
  ItemType type;

  /// Whether tax should be added to the item value
  bool isTaxable = false;

  /// Some items might consist of multiple equal parts that need to be treated separately
  int partition;
  List<AssigneeDecision> assignees = [];

  Item({
    required this.name,
    this.partition = 1,
    List<String>? assigneeUids,
    this.isTaxable = false,
    this.type = ItemType.SimpleItem,
  }) {
    var uuid = Uuid();
    this.id = uuid.v1();
    this.assignees =
        (assigneeUids ?? []).map((uid) => AssigneeDecision(uid: uid)).toList();
  }

  factory Item.fake() {
    return SimpleItem(name: 'foo', value: 0);
  }

  double get total;

  get confirmedCount => assignees.fold<double>(
        0,
        (previousValue, assignee) =>
            previousValue + (assignee.parts != null ? 1 : 0),
      );

  bool get isPartitioned => partition > 1;

  double getValueWithTax(double? tax) {
    if (tax == null || !isTaxable) return total;

    return total * (1 + tax);
  }

  double getConfirmedValueFor({
    required String uid,
    double? tax,
    bool taxOnly = false,
  }) {
    final baseValue = total * (taxOnly ? 0 : 1);
    final taxValue = total * (isTaxable && tax != null ? tax : 0);
    final totalValue = baseValue + taxValue;
    final confirmedPartition = isPartitioned ? partition : confirmedParts;

    if (confirmedPartition == 0) return 0;

    return totalValue * getAssigneeParts(uid) / confirmedPartition;
  }

  bool get completed =>
      assignees.every((assignee) => assignee.madeDecision) &&
      (!isPartitioned || undefinedParts == 0);

  /// The total number of parts that assignees already claimed
  int get confirmedParts => assignees.fold<int>(
        0,
        (acc, assignee) => acc + getAssigneeParts(assignee.uid),
      );

  int get undefinedParts => max(0, partition - confirmedParts);

  bool hasAssignee(uid) => assignees.any((assignee) => assignee.uid == uid);

  AssigneeDecision? getAssigneeById(uid) {
    return !hasAssignee(uid)
        ? null
        : assignees.firstWhere(
            (element) => element.uid == uid,
            orElse: () => throw new Exception(
              "Can not find assignee with uid $uid for item '$name' (id: $id)",
            ),
          );
  }

  bool isMarkedBy(String uid) => getAssigneeById(uid)?.madeDecision ?? true;

  int getAssigneeParts(String uid) {
    var definiteParts = getAssigneeById(uid)?.parts ?? 0;
    return isPartitioned ? definiteParts : definiteParts.clamp(0, 1);
  }

  void setAssigneeDecision(String uid, int parts) {
    var assignee = getAssigneeById(uid);

    if (assignee == null) return;

    if (isPartitioned &&
        assignee.parts != null &&
        parts > undefinedParts + assignee.parts!) return;
    assignee.parts = parts;
  }

  void resetAssigneeDecisions() {
    for (var assignee in assignees) {
      assignee.parts = null;
    }
  }

  bool get isDeniedByAll => assignees.every((assignee) => assignee.parts == 0);

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'partition': partition,
      'assignees': assignees.map((assignee) => assignee.toFirestore()).toList(),
      'taxable': isTaxable,
    };
  }

  static Item fromFirestore(Map<String, dynamic> data) {
    var uuid = Uuid();
    var type = data['type'] ?? ItemType.SimpleItem;

    Item item = Item.fake();
    switch (type) {
      case ItemType.SimpleItem:
        item = SimpleItem(
          name: data['name'],
          value: double.parse(data['value'].toString()),
        );
        break;
      case ItemType.GasItem:
        item = GasItem(
          name: data['name'],
          distance: double.parse(data['distance'].toString()),
          gasPrice: double.parse(data['gasPrice'].toString()),
          consumption: double.parse(data['consumption'].toString()),
        );
        break;
    }
    item.id = data['id'] ?? uuid.v1();
    item.assignees = data['assignees']
        .map<AssigneeDecision>(
            (assigneeData) => AssigneeDecision.fromFirestore(assigneeData))
        .toList();
    item.partition = data['partition'] ?? 1;
    item.isTaxable = data['taxable'] ?? false;
    return item;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Item &&
        other.id == id &&
        other.name == name &&
        other.total == total &&
        other.partition == partition &&
        listEquals(other.assignees, assignees) &&
        other.isTaxable == isTaxable;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        total.hashCode ^
        partition.hashCode ^
        assignees.fold(
          0,
          (previousValue, element) => previousValue ^ element.hashCode,
        ) ^
        isTaxable.hashCode;
  }
}
