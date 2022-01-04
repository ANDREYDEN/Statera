import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/services/services.dart';

class GroupService extends Firestore {
  static GroupService? _instance;

  GroupService() : super();

  static GroupService get instance {
    if (_instance == null) {
      _instance = GroupService();
    }
    return _instance!;
  }

  Future<Group> getGroup(String? groupCode) async {
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

  Future<Group> getGroupById(String? groupId) async {
    var groupDoc = await groupsCollection.doc(groupId).get();
    if (!groupDoc.exists)
      throw new Exception("There was no group with id $groupId");
    return Group.fromFirestore(
      groupDoc.data() as Map<String, dynamic>,
      id: groupDoc.id,
    );
  }

  Stream<Group?> groupStream(String? groupId) {
    return groupsCollection
        .doc(groupId)
        .snapshots()
        .map((groupSnap) => !groupSnap.exists
            ? null
            : Group.fromFirestore(
                groupSnap.data() as Map<String, dynamic>,
                id: groupSnap.id,
              ));
  }

  Future<void> deleteGroup(String? groupId) async {
    var expensesSnap =
        await expensesCollection.where('groupId', isEqualTo: groupId).get();
    await Future.wait(expensesSnap.docs.map((doc) => doc.reference.delete()));
    await groupsCollection.doc(groupId).delete();
  }

  Stream<Author> getGroupMemberStream(
      {String? groupId, required String memberId}) {
    return groupsCollection.doc(groupId).snapshots().map((groupSnap) {
      if (!groupSnap.exists) throw new Exception("No group with id $groupId");

      Group group = Group.fromFirestore(
          groupSnap.data() as Map<String, dynamic>,
          id: groupSnap.id);
      return group.getUser(memberId);
    });
  }

  Stream<Map<Author, double>> getOwingsForUserInGroup(
    String consumerUid,
    String? groupId,
  ) {
    return groupsCollection.doc(groupId).snapshots().map((groupSnap) {
      var group = Group.fromFirestore(groupSnap.data() as Map<String, dynamic>,
          id: groupSnap.id);
      return group.extendedBalance(consumerUid);
    });
  }

  Stream<List<Group>> userGroupsStream(String uid) {
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

  Future<void> createGroup(Group newGroup, User author) async {
    newGroup.generateCode();
    newGroup.addUser(author);
    await GroupService.instance.groupsCollection.add(newGroup.toFirestore());
  }

  Future<void> joinGroup(String groupCode, User user) async {
    var group = await GroupService.instance.getGroup(groupCode);
    if (group.members.any((member) => member.uid == user.uid)) return;

    group.addUser(user);
    await GroupService.instance.groupsCollection
        .doc(group.id)
        .update(group.toFirestore());

    await ExpenseService.instance
        .addUserToOutstandingExpenses(user.uid, group.id);
  }

  Future<void> saveGroup(Group group) async {
    return groupsCollection.doc(group.id).set(group.toFirestore());
  }

  Future<String> addExpense(Expense expense, Group group) async {
    expense.assignGroup(group);
    final docRef = await expensesCollection.add(expense.toFirestore());
    return docRef.id;
  }

  Stream<Group?> getExpenseGroupStream(Expense expense) {
    return groupStream(expense.groupId);
  }
}
