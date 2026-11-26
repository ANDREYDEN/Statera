import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/value_objects/aggregated_debt.dart';
import 'package:statera/utils/utils.dart';

@GenerateNiceMocks([MockSpec<UserRepository>()])
class UserRepository extends Firestore {
  UserRepository(FirebaseFirestore firestoreInstance)
    : super(firestoreInstance);

  Future<void> tryCreateUser({
    required String uid,
    required String name,
    String? photoURL,
  }) async {
    final user = CustomUser(uid: uid, name: name, photoURL: photoURL);
    final userRef = usersCollection.doc(uid);
    await usersCollection.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (snapshot.exists) return;

      transaction.set(userRef, user);
    });
  }

  /// Updates user data in `/users/{uid}`.
  /// Auth data and related group user information will be updated by the changeUser Firebase Function
  Future<void> updateUser({
    required String uid,
    String? name,
    String? photoURL,
    String? notificationToken,
    String? paymentInfo,
  }) async {
    final newUserData = {
      if (name != null) 'name': name,
      if (photoURL != null) 'photoURL': photoURL,
      if (notificationToken != null)
        'notifications.${currentPlatformName}': {
          'token': notificationToken,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        },
      if (paymentInfo != null) 'paymentInfo': paymentInfo,
    };

    await usersCollection.doc(uid).update(newUserData);
  }

  /// Sets the currency that aggregated amounts are displayed in.
  /// A null [currencyCode] removes the preference.
  Future<void> updatePreferredCurrency({
    required String uid,
    required String? currencyCode,
  }) async {
    await usersCollection.doc(uid).update({
      'preferredCurrencyCode': currencyCode ?? FieldValue.delete(),
    });
  }

  Stream<CustomUser?> userStream(String? uid) {
    return usersCollection
        .doc(uid)
        .snapshots()
        .map((docSnap) => docSnap.exists ? docSnap.data() : null);
  }

  Stream<List<Group>> sharedGroupsStream(String uid1, String uid2) {
    return groupsCollection
        .where('balance.$uid1.$uid2', isNull: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  /// Debt that [uid1] owes [uid2] in each of the [groups], in the currency
  /// of each group.
  List<DebtPart> getDebtParts(List<Group> groups, String uid1, String uid2) {
    return groups
        .map(
          (group) => (
            currency: group.currency,
            amount: group.balance[uid1]![uid2]!,
          ),
        )
        .toList();
  }

  Future<CustomUser> getUser(String uid) async {
    final userDoc = await usersCollection.doc(uid).get();

    if (!userDoc.exists) throw EntityNotFoundException(uid, name: 'User');

    return userDoc.data()!;
  }
}
