import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  late FirebaseAuth _auth;

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
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser == null) throw new Exception("Failed to log in with Google");

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  return await _auth.signInWithCredential(credential);
}
}