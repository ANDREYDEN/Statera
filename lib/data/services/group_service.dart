import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/firestore.dart';

class GroupService {
  static CollectionReference get groupsCollection => Firestore.instance.groupsCollection;


  static Future<Group> getGroup(String? groupCode) async {
    var groupSnap =
        await groupsCollection.where('code', isEqualTo: groupCode).get();
    if (groupSnap.docs.isEmpty)
      throw new Exception("There was no group with code $groupCode");
    var groupDoc = groupSnap.docs.first;
    return Group.fromFirestore(
      groupDoc.data() as Map<String, dynamic>,
      id: groupDoc.id,
    );
  }

  static Future<Group> getGroupById(String? groupId) async {
    var groupDoc = await groupsCollection.doc(groupId).get();
    if (!groupDoc.exists)
      throw new Exception("There was no group with id $groupId");
    return Group.fromFirestore(
      groupDoc.data() as Map<String, dynamic>,
      id: groupDoc.id,
    );
  }

  static Stream<Group> groupStream(String? groupId) {
    var groupStream = groupsCollection.doc(groupId).snapshots();
    return groupStream.map((groupSnap) {
      if (!groupSnap.exists)
        throw new Exception("There was no group with id $groupId");
      return Group.fromFirestore(
        groupSnap.data() as Map<String, dynamic>,
        id: groupSnap.id,
      );
    });
  }

  static Future<void> deleteGroup(String? groupId) async {
    var expensesSnap = await Firestore.instance.expensesCollection
        .where('groupId', isEqualTo: groupId)
        .get();
    await Future.wait(expensesSnap.docs.map((doc) => doc.reference.delete()));
    await Firestore.instance.groupsCollection.doc(groupId).delete();
  }

  static Stream<Author> getGroupMemberStream(
      {String? groupId, required String memberId}) {
    return groupsCollection.doc(groupId).snapshots().map((groupSnap) {
      if (!groupSnap.exists) throw new Exception("No group with id $groupId");

      Group group = Group.fromFirestore(
          groupSnap.data() as Map<String, dynamic>,
          id: groupSnap.id);
      Author? member = group.getUser(memberId);

      if (member == null)
        throw new Exception("No member in group $groupId with id $memberId");

      return member;
    });
  }

  static Stream<Map<Author, double>> getOwingsForUserInGroup(
    String consumerUid,
    String? groupId,
  ) {
    return groupsCollection.doc(groupId).snapshots().map((groupSnap) {
      var group = Group.fromFirestore(groupSnap.data() as Map<String, dynamic>,
          id: groupSnap.id);
      return group.extendedBalance(consumerUid);
    });
  }

  static Stream<List<Group>> userGroupsStream(String uid) {
    return groupsCollection
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((event) => event.docs
            .map((doc) => Group.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList());
  }

  static Future<void> saveGroup(Group group) async {
    return groupsCollection.doc(group.id).set(group.toFirestore());
  }

  static Stream<Group> getExpenseGroupStream(Expense expense) {
    return groupStream(expense.groupId);
  }
}
