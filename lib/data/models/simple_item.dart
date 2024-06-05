import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/item.dart';

class SimpleItem extends Item {
  late double value;

  SimpleItem({
    required super.name,
    required this.value,
    super.partition,
    super.assigneeUids,
    super.isTaxable,
  }) : super(type: ItemType.simple);

  @override
  double get total => value;

  @override
  Map<String, dynamic> toFirestore() {
    final base = super.toFirestore();

    return {...base, 'value': value};
  }
}
