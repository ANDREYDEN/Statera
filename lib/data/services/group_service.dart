import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/services.dart';

class GroupService extends Firestore {
  static GroupService? _instance;
  late final DynamicLinkRepository _dynamicLinkRepository;

  GroupService() : super() {
    _dynamicLinkRepository = DynamicLinkRepository();
  }

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

  Stream<List<Group>> userGroupsStream(String? uid) {
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

  /// Creates a new group and returns its Firestore id
  Future<String> createGroup(Group newGroup, User author) async {
    newGroup.generateCode();
    newGroup.addUser(author);

    final groupReference = await GroupService.instance.groupsCollection
        .add(newGroup.toFirestore());
    return groupReference.id;
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

  Future<String> addExpense(String? groupId, Expense expense) async {
    final group = await getGroupById(groupId);
    expense.assignGroup(group);
    final docRef = await expensesCollection.add(expense.toFirestore());
    return docRef.id;
  }

  Future<String> generateInviteLink(Group group) async {
    if (group.id == null)
      throw Exception('Failed to generate invite link: group does not exist');

    final link = await _dynamicLinkRepository.generateDynamicLink(
      path: 'groups/${group.id}/join/${group.code}',
      socialTitle: 'Join "${group.name}"',
      socialDescription: 'This is an invite to join a new group in Statera',
    );

    group.inviteLink = link;
    await saveGroup(group);

    return link;
  }

  Stream<Group?> getExpenseGroupStream(Expense expense) {
    return groupStream(expense.groupId);
  }

  Stream<List<Expense>> listenForUnmarkedExpenses(String? groupId, String uid) {
    return queryToExpensesStream(expensesQuery(
      groupId: groupId,
      unmarkedAssigneeId: uid,
    ));
  }
}
