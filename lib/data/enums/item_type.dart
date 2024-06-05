enum ItemType {
  gas,
  simple;

  String toFirestore() => name;
  static ItemType? fromFirestore(String? name) =>
      name == null || !values.any((v) => v.name == name)
          ? null
          : values.byName(name);
}
