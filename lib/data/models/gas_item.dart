import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/item.dart';

class GasItem extends Item {
  double distance;
  double gasPrice;
  double consumption;

  GasItem({
    required super.name,
    required this.distance,
    required this.gasPrice,
    required this.consumption,
    super.assigneeUids,
  }) : super(type: ItemType.gas);

  @override
  double get total => distance * gasPrice * consumption / 100;

  @override
  Map<String, dynamic> toFirestore() {
    final base = super.toFirestore();

    return {
      ...base,
      'distance': distance,
      'gasPrice': gasPrice,
      'consumption': consumption
    };
  }
}
