import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/value_objects/profile_part.dart';
import 'package:uuid/uuid.dart';

class CustomUser {
  late String uid;
  late String name;
  String? photoURL;
  String? paymentInfo;

  CustomUser({
    required this.uid,
    required this.name,
    this.photoURL,
    this.paymentInfo,
  });

  CustomUser.fromUser(User user) {
    this.uid = user.uid;
    this.name = user.displayName ?? 'anonymous';
    this.photoURL = user.photoURL;
  }

  CustomUser.fake({String? name, String? uid, String? photoURL}) {
    this.uid = uid ?? Uuid().v1();
    this.name = name ?? 'bar';
    this.photoURL = photoURL;
  }

  List<ProfilePart> get profileParts => [
        ProfilePart(
          name: 'Set a username',
          incompleteMessage:
              'Please provide a username, otherwise you would be visible to others as "anonymous"',
          isCompleted: name != 'anonymous',
        ),
        ProfilePart(
          name: 'Set a Profile Picture',
          incompleteMessage: 'Make it easier for others to recognize you',
          isCompleted: photoURL != null,
        ),
        ProfilePart(
          name: 'Set Payment Information',
          incompleteMessage:
              'Please provide your payment information so that others know how to pay you',
          isCompleted: paymentInfo != null,
        ),
      ];

  List<ProfilePart> get incompletedProfileParts =>
      profileParts.where((part) => !part.isCompleted).toList();

  List<ProfilePart> get completedProfileParts =>
      profileParts.where((part) => part.isCompleted).toList();

  int get completionPercentage =>
      (completedProfileParts.length / profileParts.length * 100).toInt();

  static CustomUser fromUserDoc(DocumentSnapshot<Object?> doc) {
    final docData = doc.data() as Map<String, dynamic>;
    return CustomUser(
      uid: doc.id,
      name: docData['name'] ?? 'anonymous',
      photoURL: docData['photoURL'],
      paymentInfo: docData['paymentInfo'],
    );
  }

  static CustomUser fromFirestore(Map<String, dynamic> data) {
    return CustomUser(
      uid: data['uid'],
      name: data['name'] ?? 'anonymous',
      photoURL: data['photoURL'],
      paymentInfo: data['paymentInfo'],
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
