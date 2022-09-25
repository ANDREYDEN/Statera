import 'package:statera/data/services/firestore.dart';

class UserRepository extends Firestore {
  /// Updates user data in `/users/{uid}`. 
  /// Auth data and related group user information will be updated by the changeUser Firebase Function
  Future<void> updateUser(String uid, String? name, String? photoURL) async {
    final newUserData = {
      if (name != null) 
        'name': name,
      if (photoURL != null) 
        'photoURL': photoURL
    };

    await usersCollection.doc(uid).update(newUserData);
  }
}