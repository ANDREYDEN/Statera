import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:statera/business_logic/group_joining/group_joining_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

class MockGroupService extends Mock implements GroupService {}

class MockUser extends Mock implements User {}

class FakeUser extends Fake implements User {}

void main() {
  group('GroupJoiningCubit', () {
    late GroupJoiningCubit groupJoiningCubit;
    late GroupService groupService;
    late User testUser;
    final String testCode = 'qweqwe321';
    final Group testGroup = Group.fake(code: testCode);

    setUpAll(() {
      registerFallbackValue(FakeUser());
    });

    setUp(() {
      groupService = MockGroupService();
      testUser = MockUser();
      groupJoiningCubit = GroupJoiningCubit(testGroup, groupService);
      when(() => groupService.joinGroup(any(), any())).thenAnswer((_) async {});
      when(() => testUser.uid).thenAnswer((_) => 'qwe145');
    });

    test('has initial state is GroupJoiningLoaded', () {
      expect(groupJoiningCubit.state, GroupJoiningLoaded(group: testGroup));
    });

    blocTest(
      'can successfully join a group',
      build: () => groupJoiningCubit,
      act: (GroupJoiningCubit cubit) => cubit.join(testCode, testUser),
      expect: () => [GroupJoiningLoading(), GroupJoiningSuccess()],
      verify: (_) {
        verify(() => groupService.joinGroup(testCode, testUser)).called(1);
      },
    );

    blocTest(
      'emmits an error state if the code does not match the group code',
      build: () => groupJoiningCubit,
      act: (GroupJoiningCubit cubit) => cubit.join('some other code', testUser),
      expect: () => [GroupJoiningError(error: 'Invalid invitation. Make sure you have copied the link correctly.')],
      verify: (_) {
        verifyNever(() => groupService.joinGroup(any(), any()));
      },
    );

    blocTest(
      'emmits error state if the user is already a member of the group',
      build: () {
        Group testGroup = Group.fake(code: 'qwe123');
        testGroup.addUser(testUser);
        return GroupJoiningCubit(testGroup, groupService);
      },
      act: (GroupJoiningCubit cubit) => cubit.join('qwe123', testUser),
      expect: () => [GroupJoiningError(error: 'You are already a member of this group')],
      verify: (_) {
        verifyNever(() => groupService.joinGroup(any(), any()));
      },
    );
  });
}
