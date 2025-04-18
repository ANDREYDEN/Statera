import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/utils/utils.dart';

@GenerateNiceMocks([MockSpec<UserRepository>()])
class UserRepository extends Firestore {
  UserRepository(FirebaseFirestore firestoreInstance)
      : super(firestoreInstance);

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

  Stream<CustomUser?> userStream(String? uid) {
    return usersCollection.doc(uid).snapshots().map(
        (docSnap) => docSnap.exists ? CustomUser.fromUserDoc(docSnap) : null);
  }

  Future<CustomUser> getUser(String uid) async {
    final userDoc = await usersCollection.doc(uid).get();

    if (!userDoc.exists) throw EntityNotFoundException(uid, name: 'User');

    return CustomUser.fromUserDoc(userDoc);
  }
}
