import 'package:json_annotation/json_annotation.dart';
import 'package:statera/data/enums/item_type.dart';
import 'package:statera/data/models/models.dart';

class ItemsListConverter implements JsonConverter<List<Item>, List<dynamic>> {
  const ItemsListConverter();

  @override
  List<Item> fromJson(List<dynamic> json) {
    return json
        .map((item) => _itemFromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  List<dynamic> toJson(List<Item> objects) =>
      objects.map((o) => o.toJson()).toList();
}

Item _itemFromJson(Map<String, dynamic> json) {
  var type = ItemType.fromString(json['type']) ?? ItemType.simple;

  switch (type) {
    case ItemType.simple:
      return SimpleItem.fromJson(json);
    case ItemType.gas:
      return GasItem.fromJson(json);
  }
}
