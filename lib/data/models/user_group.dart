import 'package:cloud_firestore/cloud_firestore.dart';

class UserGroup {
  String groupId;
  String name;
  int unmarkedExpenses;
  int memberCount;

  UserGroup({
    required this.groupId,
    required this.name,
    this.unmarkedExpenses = 0,
    this.memberCount = 0,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'name': name,
      'unmarkedExpenses': unmarkedExpenses,
      'memberCount': memberCount,
    };
  }

  static UserGroup fromFirestore(Map<String, dynamic> data, String id) {
    assert(data['name'] is String);
    return UserGroup(
      groupId: data['groupId'],
      name: data['name'],
      unmarkedExpenses: data['unmarkedExpenses'],
      memberCount: data['memberCount'],
    );
  }

  static UserGroup fromSnapshot(QueryDocumentSnapshot snap) {
    return fromFirestore(snap.data() as Map<String, dynamic>, snap.id);
  }
}
