import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/error_service_mock.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/utils/constants.dart';

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
}

final userCredential = MockUserCredential();

void main() {
  group('SignInCubit', () {
    final String uid = 'foo';
    final String displayName = 'John Doe';
    late MockUser mockUser;
    late SignInCubit signInCubit;
    late MockAuthService authService;
    late MockUserRepository userRepository;

    setUp(() {
      authService = MockAuthService();
      userRepository = MockUserRepository();
      signInCubit = SignInCubit(
        authService,
        MockErrorService(),
        userRepository,
      );
      mockUser = MockUser();

      when(mockUser.uid).thenReturn(uid);
      when(mockUser.displayName).thenReturn(displayName);
      when(userCredential.user).thenReturn(mockUser);
      when(
        authService.signIn(any, any),
      ).thenAnswer((_) async => userCredential);
      when(
        authService.signUp(any, any),
      ).thenAnswer((_) async => userCredential);
      when(
        authService.signInWithGoogle(),
      ).thenAnswer((_) async => userCredential);
    });

    test('initial state is SignInLoaded', () {
      expect(signInCubit.state, SignInLoaded());
    });

    group('Sign In with email and password', () {
      blocTest(
        'emits [SignInLoading, SignInLoaded] when signIn is called',
        build: () => signInCubit,
        act: (SignInCubit cubit) => cubit.signIn('email', 'password'),
        expect: () => [SignInLoading(), SignInLoaded()],
        verify: (_) {
          verify(authService.signIn(any, any)).called(1);
        },
      );

      blocTest(
        'emits SignInError when signIn throws',
        setUp: () {
          when(
            authService.signIn(any, any),
          ).thenThrow(FirebaseAuthException(code: 'invalid-email'));
        },
        build: () => signInCubit,
        act: (SignInCubit cubit) => cubit.signIn('email', 'password'),
        expect: () => [
          SignInLoading(),
          SignInError(error: kSignInMessages['invalid-email']!),
        ],
        verify: (_) {
          verify(authService.signIn(any, any)).called(1);
        },
      );
    });

    group('Sign Up with email and password', () {
      blocTest(
        'emits [SignInLoading, SignInLoaded] when signUp is called',
        build: () => signInCubit,
        act: (SignInCubit cubit) =>
            cubit.signUp('New Name', 'email', 'password', 'password'),
        expect: () => [SignInLoading(), SignInLoaded()],
        verify: (_) {
          verify(authService.signUp(any, any)).called(1);
          verify(
            userRepository.tryCreateUser(
              uid: uid,
              name: 'New Name',
              photoURL: null,
            ),
          ).called(1);
        },
      );

      blocTest(
        'emits [SignInLoading, SignInError] when signUp throws',
        setUp: () {
          when(
            authService.signUp(any, any),
          ).thenThrow(FirebaseAuthException(code: 'weak-password'));
        },
        build: () => signInCubit,
        act: (SignInCubit cubit) =>
            cubit.signUp('John Doe', 'email', 'password', 'password'),
        expect: () => [
          SignInLoading(),
          SignInError(error: kSignUpMessages['weak-password']!),
        ],
        verify: (_) {
          verify(authService.signUp(any, any)).called(1);
        },
      );
    });

    group('Sign In/Up with Google', () {
      blocTest(
        'emits [SignInLoading, SignInLoaded] when signInWithGoogle is called',
        build: () => signInCubit,
        act: (SignInCubit cubit) => cubit.signInWithGoogle(),
        expect: () => [SignInLoading(), SignInLoaded()],
        verify: (_) {
          verify(authService.signInWithGoogle()).called(1);
          verify(
            userRepository.tryCreateUser(uid: uid, name: displayName),
          ).called(1);
        },
      );

      blocTest(
        'emits SignInError when signInWithGoogle throws',
        setUp: () {
          when(
            authService.signInWithGoogle(),
          ).thenThrow(FirebaseAuthException(code: 'user-disabled'));
        },
        build: () => signInCubit,
        act: (SignInCubit cubit) => cubit.signInWithGoogle(),
        expect: () => [
          SignInLoading(),
          SignInError(error: kFirebaseAuthErrorMessages['user-disabled']!),
        ],
        verify: (_) {
          verify(authService.signInWithGoogle()).called(1);
        },
      );
    });
  });
}
