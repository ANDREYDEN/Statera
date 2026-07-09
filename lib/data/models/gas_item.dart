import 'package:json_annotation/json_annotation.dart';
import 'package:statera/data/enums/enums.dart';

import 'assignee_decision.dart';
import 'item.dart';

part 'gas_item.g.dart';

@JsonSerializable()
class GasItem extends Item {
  double distance;
  double gasPrice;
  double consumption;

  GasItem({
    required super.name,
    required this.distance,
    required this.gasPrice,
    required this.consumption,
    super.partition,
    super.assigneeUids,
    super.assignees,
    super.isTaxable,
    super.id,
  }) : super(type: ItemType.gas);

  @override
  double get total => distance * gasPrice * consumption / 100;

  factory GasItem.fromJson(Map<String, dynamic> data) =>
      _$GasItemFromJson(data);

  @override
  Map<String, dynamic> toJson() => _$GasItemToJson(this);

  static GasItem from(GasItem other) {
    return GasItem(
      name: other.name,
      distance: other.distance,
      gasPrice: other.gasPrice,
      consumption: other.consumption,
    );
  }
}
