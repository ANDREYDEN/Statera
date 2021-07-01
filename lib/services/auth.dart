import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:statera/services/firestore.dart';

class Auth {
  late FirebaseAuth _auth;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  Auth._privateConstructor() {
    _auth = FirebaseAuth.instance;
  }

  static Auth get instance => Auth._privateConstructor();

  User? get currentUser => _auth.currentUser;

  Stream<User?> currentUserStream() {
    return _auth.authStateChanges();
  }

  Future<User> currentUserOrThrow() async {
    var user = await _auth.authStateChanges().first;
    if (user == null) throw Exception("Tried to get a user when not logged in.");
    return user;
  }

  
Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

  if (googleUser == null) throw new Exception("Failed to log in with Google");

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );


  final userCredential = await _auth.signInWithCredential(credential);


  await Firestore.instance.addUserToGroup(userCredential.user!);

  return userCredential;
}

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _auth.signOut();
  }
}