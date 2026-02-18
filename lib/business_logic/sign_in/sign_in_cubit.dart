import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/utils.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  late final AuthService _authRepository;
  late final ErrorService _errorService;
  late final UserRepository _userRepository;

  SignInCubit(
    AuthService authRepository,
    ErrorService errorService,
    UserRepository userRepository,
  ) : super(SignInLoaded()) {
    _authRepository = authRepository;
    _errorService = errorService;
    _userRepository = userRepository;
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
      emit(
        SignInError(error: 'Something went wrong: ${genericError.toString()}'),
      );
    }
  }

  Future<void> signUp(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      emit(SignInLoading());
      final userCredential = await _authRepository.signUp(
        email,
        password,
        confirmPassword,
      );
      await _userRepository.tryCreateUser(
        uid: userCredential.user!.uid,
        name: name,
      );

      emit(SignInLoaded());
    } on FirebaseAuthException catch (firebaseError) {
      final message = kSignUpMessages.containsKey(firebaseError.code)
          ? kSignUpMessages[firebaseError.code]!
          : 'Error while authenticating: ${firebaseError.message}';
      emit(SignInError(error: message));
    } catch (genericError) {
      emit(
        SignInError(error: 'Something went wrong: ${genericError.toString()}'),
      );
    }
  }

  signInWithGoogle() async {
    try {
      emit(SignInLoading());
      final userCredential = await _authRepository.signInWithGoogle();
      final user = userCredential?.user;
      if (user != null) {
        await _userRepository.tryCreateUser(
          uid: user.uid,
          name: user.displayName ?? 'anonymous',
          photoURL: user.photoURL,
        );
      }
      emit(SignInLoaded());
    } on FirebaseAuthException catch (firebaseError) {
      final message = kFirebaseAuthErrorMessages.containsKey(firebaseError.code)
          ? kFirebaseAuthErrorMessages[firebaseError.code]!
          : 'Error while authenticating: ${firebaseError.message}';
      emit(SignInError(error: message));
    } on Exception catch (genericError) {
      emit(
        SignInError(
          error: 'Something went wrong while signing in with Google.',
        ),
      );
      await _errorService.recordError(
        genericError,
        reason: 'Sign In with Google Failed',
      );
    }
  }

  signInWithApple() async {
    try {
      emit(SignInLoading());
      final userCredential = await _authRepository.signInWithApple();
      final user = userCredential.user;
      if (user != null) {
        await _userRepository.tryCreateUser(
          uid: user.uid,
          name: user.displayName ?? 'anonymous',
          photoURL: user.photoURL,
        );
      }
      emit(SignInLoaded());
    } on FirebaseAuthException catch (firebaseError) {
      final message = kFirebaseAuthErrorMessages.containsKey(firebaseError.code)
          ? kFirebaseAuthErrorMessages[firebaseError.code]!
          : 'Error while authenticating: ${firebaseError.message}';
      emit(SignInError(error: message));
    } catch (genericError) {
      emit(
        SignInError(error: 'Something went wrong while signing in with Apple.'),
      );
      await _errorService.recordError(
        genericError,
        reason: 'Sign In with Apple Failed',
      );
    }
  }

  clearError() {
    if (state is SignInError) emit(SignInLoaded());
  }
}
