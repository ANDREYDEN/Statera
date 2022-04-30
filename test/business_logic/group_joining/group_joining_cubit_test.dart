import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:statera/business_logic/group_joining/group_joining_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/auth_repository.dart';

// class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('GroupJoiningCubit', () {
    late GroupJoiningCubit groupJoiningCubit;
    Group group = Group.fake();

    setUp(() {
      // authRepository = MockAuthRepository();
      groupJoiningCubit = GroupJoiningCubit(group);
      // when(() => authRepository.signIn(any(), any()))
      //     .thenAnswer((_) async => userCredential);
      // when(() => authRepository.signUp(any(), any(), any()))
      //     .thenAnswer((_) async => userCredential);
      // when(() => authRepository.signInWithGoogle())
      //     .thenAnswer((_) async => userCredential);
    });

    test('initial state is GroupJoiningLoaded', () {
      expect(groupJoiningCubit.state, GroupJoiningLoaded(group: group));
    });

    blocTest(
      'can successfully join a group',
      build: () => groupJoiningCubit,
      act: (GroupJoiningCubit cubit) => cubit.join(),
      expect: () => [GroupJoiningLoading(), GroupJoiningSuccess()]
    );
  });
}
