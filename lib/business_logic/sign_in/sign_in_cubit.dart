import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/utils.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  late final AuthService _authRepository;

  SignInCubit(AuthService authRepository) : super(SignInLoaded()) {
    _authRepository = authRepository;
  }

  Future<void> signIn(String email, String password) async {
    try {
      emit(SignInLoading());
      await _authRepository.signIn(email, password);
      emit(SignInLoaded());
    } on FirebaseAuthException catch (firebaseError) {
      final message = kSignInMessages.containsKey(firebaseError.code)
          ? kSignInMessages[firebaseError.code]!
          : 'Error while authenticating: ${firebaseError.message}';
      emit(SignInError(error: message));
    } catch (genericError) {
      emit(SignInError(
          error: 'Something went wrong: ${genericError.toString()}'));
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      emit(SignInLoading());
      await _authRepository.signUp(email, password, confirmPassword);
      emit(SignInLoaded());
    } on FirebaseAuthException catch (firebaseError) {
      final message = kSignUpMessages.containsKey(firebaseError.code)
          ? kSignUpMessages[firebaseError.code]!
          : 'Error while authenticating: ${firebaseError.message}';
      emit(SignInError(error: message));
    } catch (genericError) {
      emit(SignInError(
          error: 'Something went wrong: ${genericError.toString()}'));
    }
  }

  signInWithGoogle() async {
    try {
      emit(SignInLoading());
      final signInTask = _authRepository.signInWithGoogle();
      final timeout = Future.delayed(
        Duration(seconds: 20),
        () => throw Exception('Timeout'),
      );
      await Future.any([timeout, signInTask]);
      emit(SignInLoaded());
    } on FirebaseAuthException catch (firebaseError) {
      final message = kSignInWithGoogleMessages.containsKey(firebaseError.code)
          ? kSignInWithGoogleMessages[firebaseError.code]!
          : 'Error while authenticating: ${firebaseError.message}';
      emit(SignInError(error: message));
    } on Exception catch (genericError) {
      await FirebaseCrashlytics.instance.recordError(
        genericError,
        null,
        reason: 'Sign In with Google Failed',
      );
      print(genericError);
      emit(
        SignInError(error: 'Something went wrong: ${genericError.toString()}'),
      );
    }
  }

  signInWithApple() async {
    try {
      emit(SignInLoading());
      await _authRepository.signInWithApple();
      emit(SignInLoaded());
    } on FirebaseAuthException catch (firebaseError) {
      final message = kSignInWithGoogleMessages.containsKey(firebaseError.code)
          ? kSignInWithGoogleMessages[firebaseError.code]!
          : 'Error while authenticating: ${firebaseError.message}';
      emit(SignInError(error: message));
    } catch (genericError) {
      emit(
        SignInError(error: 'Something went wrong: ${genericError.toString()}'),
      );
    }
  }
}
