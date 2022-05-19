import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  late FirebaseAuth _auth;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepository() {
    _auth = FirebaseAuth.instance;
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> currentUserStream() {
    return _auth.authStateChanges();
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(
      String email, String password, String confirmPassword) {
    if (password != confirmPassword) {
      throw FirebaseAuthException(code: 'password-mismatch');
    }
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
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

    return await _auth.signInWithCredential(credential);
  }

  Future<void> signInWithApple() async {
    await (kIsWeb ? signInWithAppleOnWeb() : signInWithAppleOnMobile());
  }

  Future<UserCredential?> signInWithAppleOnWeb() async {
    final provider = OAuthProvider('apple.com');
    provider.addScope('email');
    provider.addScope('name');

    return await _auth.signInWithPopup(provider);
  }

  Future<AuthorizationCredentialAppleID?> signInWithAppleOnMobile() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    return credential;
  }
}
