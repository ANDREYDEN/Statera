import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/services.dart';

@GenerateNiceMocks([MockSpec<GroupRepository>()])
class GroupRepository extends Firestore {
  late final DynamicLinkService _dynamicLinkService;

  GroupRepository(FirebaseFirestore firestoreInstance)
      : super(firestoreInstance) {
    _dynamicLinkService = DynamicLinkService();
  }

  Future<Group> getGroup(String? groupCode) async {
    var groupSnap =
        await groupsCollection.where('code', isEqualTo: groupCode).get();
    if (groupSnap.docs.isEmpty)
      throw new Exception('There was no group with code $groupCode');
    var groupDoc = groupSnap.docs.first;
    return groupDoc.data();
  }

  Future<Group> getGroupById(String? groupId) async {
    var groupDoc = await groupsCollection.doc(groupId).get();
    final group = groupDoc.data();

    if (!groupDoc.exists || group == null) {
      throw new Exception('There was no group with id $groupId');
    }

    return group;
  }

  Stream<Group?> groupStream(String? groupId) {
    return groupsCollection
        .doc(groupId)
        .snapshots()
        .map((groupSnap) => groupSnap.data());
  }

  Future<void> deleteGroup(String? groupId) async {
    // a Cloud Function handles deleting related data
    await groupsCollection.doc(groupId).delete();
  }

  Stream<CustomUser> getGroupMemberStream({
    String? groupId,
    required String memberId,
  }) {
    return groupStream(groupId).map((group) {
      if (group == null) {
        throw EntityNotFoundException<Group>(groupId);
      }

      return group.getMember(memberId);
    });
  }

  /// Creates a new group and returns its Firestore id
  Future<String> createGroup(Group newGroup, CustomUser user) async {
    newGroup.addMember(user);

    final groupReference = await groupsCollection.add(newGroup);
    return groupReference.id;
  }

  Future<Group> addMember(String groupCode, CustomUser user) async {
    var group = await getGroup(groupCode);
    if (group.members.any((member) => member.uid == user.uid)) {
      throw Exception('Member ${user.uid} already exists');
    }

    group.addMember(user);
    await groupsCollection.doc(group.id).update(group.toFirestore());

    return group;
  }

  Future<void> saveGroup(Group group) {
    return groupsCollection.doc(group.id).set(group);
  }

  Future<String> addExpense(String? groupId, Expense expense) async {
    final group = await getGroupById(groupId);
    expense.groupId = groupId;
    expense.settings = group.defaultExpenseSettings;
    final docRef = await expensesCollection.add(expense.toFirestore());
    return docRef.id;
  }

  Future<String> generateInviteLink(Group group) async {
    if (group.id == null)
      throw Exception('Failed to generate invite link: group does not exist');

    final link = await _dynamicLinkService.generateDynamicLink(
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
