import 'package:json_annotation/json_annotation.dart';
import 'package:statera/data/enums/enums.dart';

import 'assignee_decision.dart';
import 'item.dart';

part 'simple_item.g.dart';

@JsonSerializable()
class SimpleItem extends Item {
  late double value;

  SimpleItem({
    required super.name,
    required this.value,
    super.partition,
    super.assigneeUids,
    super.assignees,
    super.isTaxable,
    super.id,
  }) : super(type: ItemType.simple);

  @override
  double get total => value;

  factory SimpleItem.fromJson(Map<String, dynamic> data) =>
      _$SimpleItemFromJson(data);

  @override
  Map<String, dynamic> toJson() => _$SimpleItemToJson(this);

  static SimpleItem from(SimpleItem other) {
    return SimpleItem(name: other.name, value: other.value);
  }
}
