import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';

class Firestore {
  late FirebaseFirestore _firestore;
  static Firestore? _instance;

  Firestore._privateConstructor() {
    // FirebaseFirestore.instance.settings = Settings(host: '10.0.2.2:9099');
    _firestore = FirebaseFirestore.instance;
  }

  static Firestore get instance {
    if (_instance == null) {
      _instance = Firestore._privateConstructor();
    }
    return _instance!;
  }

  CollectionReference get expensesCollection =>
      _firestore.collection("expenses");

  CollectionReference get groupsCollection => _firestore.collection("groups");

  CollectionReference get paymentsCollection =>
      _firestore.collection("payments");

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

  Stream<Group> groupStream(String? groupId) {
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

  Future<String> addExpenseToGroup(Expense expense, String? groupCode) async {
    var group = await getGroup(groupCode);
    expense.assignGroup(group);
    final docRef = await expensesCollection.add(expense.toFirestore());
    return docRef.id;
  }

  Future<void> deleteGroup(String? groupId) async {
    var expensesSnap = await Firestore.instance.expensesCollection
        .where('groupId', isEqualTo: groupId)
        .get();
    await Future.wait(expensesSnap.docs.map((doc) => doc.reference.delete()));
    await Firestore.instance.groupsCollection.doc(groupId).delete();
  }

  Stream<Author> getGroupMemberStream(
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

  Future<void> payOffBalance({required Payment payment}) async {
    Group group = await getGroupById(payment.groupId);
    group.payOffBalance(payment: payment);
    await paymentsCollection.add(payment.toFirestore());
    await saveGroup(group);
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

  Future<void> saveGroup(Group group) async {
    return groupsCollection.doc(group.id).set(group.toFirestore());
  }

  Stream<Group> getExpenseGroupStream(Expense expense) {
    return this.groupStream(expense.groupId);
  }
}
