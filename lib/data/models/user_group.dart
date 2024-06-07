class UserGroup {
  String name;
  int unmarkedExpenses;
  int memberCount;

  UserGroup({
    required this.name,
    this.unmarkedExpenses = 0,
    this.memberCount = 0,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'unmarkedExpenses': unmarkedExpenses,
      'memberCount': memberCount,
    };
  }

  static UserGroup fromFirestore(Map<String, dynamic> data, String id) {
    assert(data['name'] is String);
    return UserGroup(
      name: data['name'],
      unmarkedExpenses: data['unmarkedExpenses'],
      memberCount: data['memberCount'],
    );
  }
}
