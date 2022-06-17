import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
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
    final provider = OAuthProvider('apple.com')
      ..addScope('email')
      ..addScope('name');

    return _auth.signInWithPopup(provider);
  }

  Future<UserCredential?> signInWithAppleOnMobile() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ], nonce: nonce);

    final oAuthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    return _auth.signInWithCredential(oAuthCredential);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
