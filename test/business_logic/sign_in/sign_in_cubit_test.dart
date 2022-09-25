import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/constants.dart';

class MockAuthRepository extends Mock implements AuthService {}

class MockUserCredential extends Mock implements UserCredential {}

final userCredential = MockUserCredential();

void main() {
  group('SignInCubit', () {
    late SignInCubit signInCubit;
    late AuthService authRepository;

    setUp(() {
      authRepository = MockAuthRepository();
      signInCubit = SignInCubit(authRepository);
      when(() => authRepository.signIn(any(), any()))
          .thenAnswer((_) async => userCredential);
      when(() => authRepository.signUp(any(), any(), any()))
          .thenAnswer((_) async => userCredential);
      when(() => authRepository.signInWithGoogle())
          .thenAnswer((_) async => userCredential);
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
          verify(() => authRepository.signIn(any(), any())).called(1);
        },
      );

      blocTest(
        'emits SignInError when signIn throws',
        setUp: () {
          when(() => authRepository.signIn(any(), any()))
              .thenThrow(FirebaseAuthException(code: 'invalid-email'));
        },
        build: () => signInCubit,
        act: (SignInCubit cubit) => cubit.signIn('email', 'password'),
        expect: () => [
          SignInLoading(),
          SignInError(error: kSignInMessages['invalid-email']!)
        ],
        verify: (_) {
          verify(() => authRepository.signIn(any(), any())).called(1);
        },
      );
    });

    group('Sign Up with email and password', () {
      blocTest(
        'emits [SignInLoading, SignInLoaded] when signUp is called',
        build: () => signInCubit,
        act: (SignInCubit cubit) =>
            cubit.signUp('email', 'password', 'password'),
        expect: () => [SignInLoading(), SignInLoaded()],
        verify: (_) {
          verify(() => authRepository.signUp(any(), any(), any())).called(1);
        },
      );

      blocTest(
        'emits [SignInLoading, SignInError] when signUp throws',
        setUp: () {
          when(() => authRepository.signUp(any(), any(), any()))
              .thenThrow(FirebaseAuthException(code: 'weak-password'));
        },
        build: () => signInCubit,
        act: (SignInCubit cubit) =>
            cubit.signUp('email', 'password', 'password'),
        expect: () => [
          SignInLoading(),
          SignInError(error: kSignUpMessages['weak-password']!)
        ],
        verify: (_) {
          verify(() => authRepository.signUp(any(), any(), any())).called(1);
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
          verify(() => authRepository.signInWithGoogle()).called(1);
        },
      );

      blocTest(
        'emits SignInError when signInWithGoogle throws',
        setUp: () {
          when(() => authRepository.signInWithGoogle())
              .thenThrow(FirebaseAuthException(code: 'user-disabled'));
        },
        build: () => signInCubit,
        act: (SignInCubit cubit) => cubit.signInWithGoogle(),
        expect: () => [
          SignInLoading(),
          SignInError(error: kSignInWithGoogleMessages['user-disabled']!)
        ],
        verify: (_) {
          verify(() => authRepository.signInWithGoogle()).called(1);
        },
      );
    });
  });
}
