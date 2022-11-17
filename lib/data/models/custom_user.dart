import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomUser {
  late String uid;
  late String name;
  String? photoURL;

  CustomUser({required this.uid, required this.name, this.photoURL});

  CustomUser.fromUser(User user) {
    this.uid = user.uid;
    this.name = user.displayName ?? 'anonymous';
    this.photoURL = user.photoURL;
  }

  CustomUser.fake({String? name, String? uid, String? photoURL}) {
    this.uid = uid ?? 'foo';
    this.name = name ?? 'bar';
    this.photoURL = photoURL ?? 'baz';
  }

  static CustomUser fromUserDoc(DocumentSnapshot<Object?> doc) {
    final docData = doc.data() as Map<String, dynamic>;
    return CustomUser(
      uid: doc.id,
      name: docData['name'] ?? 'anonymous',
      photoURL: docData['photoURL'],
    );
  }

  static CustomUser fromFirestore(Map<String, dynamic> data) {
    return CustomUser(
      uid: data['uid'],
      name: data['name'] ?? 'anonymous',
      photoURL: data['photoURL'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'photoURL': photoURL,
    };
  }
}
