import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  late FirebaseAuth _auth;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static Auth? _instance;

  Auth._privateConstructor() {
    _auth = FirebaseAuth.instance;
  }

  static Auth get instance {
    if (_instance == null) {
      _instance = Auth._privateConstructor();
    } 
    return _instance!; 
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> currentUserStream() {
    return _auth.authStateChanges();
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signInWithGoogle() async {
    return kIsWeb
        ? _auth.signInWithPopup(GoogleAuthProvider())
        : this.signInWithGoogleOnMobile();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential?> signInWithGoogleOnMobile() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) throw new Exception("Failed to log in with Google");

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    return userCredential;
  }
}
