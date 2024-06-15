import 'package:cloud_firestore/cloud_firestore.dart';

class UserGroup {
  String groupId;
  String name;
  int unmarkedExpenses;
  int memberCount;
  bool archived;
  bool pinned;

  UserGroup({
    required this.groupId,
    required this.name,
    this.unmarkedExpenses = 0,
    this.memberCount = 0,
    this.archived = false,
    this.pinned = false,
  });

  void toggleArchive() {
    if (archived) {
      archived = false;
      return;
    }

    pinned = false;
    archived = true;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'name': name,
      'unmarkedExpenses': unmarkedExpenses,
      'memberCount': memberCount,
      'archived': archived,
      'pinned': pinned,
    };
  }

  static UserGroup fromFirestore(Map<String, dynamic> data, String id) {
    assert(data['name'] is String);
    return UserGroup(
        groupId: data['groupId'],
        name: data['name'],
        unmarkedExpenses: data['unmarkedExpenses'] ?? 0,
        memberCount: data['memberCount'] ?? 0,
        archived: data['archived'] ?? false,
        pinned: data['pinned'] ?? false);
  }

  static UserGroup fromSnapshot(QueryDocumentSnapshot snap) {
    return fromFirestore(snap.data() as Map<String, dynamic>, snap.id);
  }
}
