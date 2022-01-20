import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/services.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(SignInLoaded());

  signIn(String email, String password) async {
    try {
      emit(SignInLoading());
      await Auth.instance.signIn(email, password);
      emit(SignInLoaded());
    } on FirebaseAuthException catch (firebaseError) {
      const messages = {
        'user-not-found': 'There is no user associated with this email address',
        'invalid-email': 'The provided email is not valid',
        'user-disabled': 'This user has been disabled',
        'wrong-password': 'Invalid credentials',
      };
      final message = messages.containsKey(firebaseError.code)
          ? messages[firebaseError.code]!
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
      await Auth.instance.signInWithGoogle();
      emit(SignInLoaded());
    } on FirebaseAuthException catch (firebaseError) {
      const messages = {
        'user-not-found': 'There is no user associated with this email address',
        'user-disabled': 'This user has been disabled',
      };
      final message = messages.containsKey(firebaseError.code)
          ? messages[firebaseError.code]!
          : 'Error while authenticating: ${firebaseError.message}';
      emit(SignInError(error: message));
    } catch (genericError) {
      emit(SignInError(
          error: 'Something went wrong: ${genericError.toString()}'));
    }
  }
}
