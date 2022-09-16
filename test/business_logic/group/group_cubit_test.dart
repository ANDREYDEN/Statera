import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

class MockGroupService extends Mock implements GroupService {}

class MockExpenseService extends Mock implements ExpenseService {}

class MockUser extends Mock implements User {}

class FakeUser extends Fake implements User {}

void main() {
  group('GroupCubit', () {
    late GroupCubit groupCubit;
    late GroupService groupService;
    late ExpenseService expenseService;
    late User testUser;
    final String testCode = 'qweqwe321';
    final Group testGroup = Group.empty(code: testCode);

    setUpAll(() {
      registerFallbackValue(FakeUser());
    });

    setUp(() {
      groupService = MockGroupService();
      expenseService = MockExpenseService();
      testUser = MockUser();
      groupCubit = GroupCubit(groupService, expenseService);
      when(() => groupService.groupStream(any()))
          .thenAnswer((_) => Stream.fromIterable([testGroup]));
      when(() => groupService.joinGroup(any(), any())).thenAnswer((_) async {});
      when(() => testUser.uid).thenAnswer((_) => 'qwe145');
    });

    test('has initial state of GroupLoading', () {
      expect(groupCubit.state, GroupLoading());
    });

    blocTest(
      'has state of GroupLoaded once loaded',
      build: () => groupCubit,
      act: (GroupCubit cubit) => cubit.load(testGroup.id),
      expect: () => [GroupLoaded(group: testGroup)],
      verify: (_) {
        verify(() => groupService.groupStream(testGroup.id)).called(1);
      },
    );

    group('when joining', () {
      blocTest<GroupCubit, GroupState>(
        'can successfully join a group',
        build: () => groupCubit,
        seed: () => GroupLoaded(group: testGroup),
        act: (cubit) => cubit.join(testCode, testUser),
        expect: () => [GroupLoading(), GroupJoinSuccess()],
        verify: (_) {
          verify(() => groupService.joinGroup(testCode, testUser)).called(1);
        },
      );

      blocTest<GroupCubit, GroupState>(
        'emmits an error state if the code does not match the group code',
        build: () => groupCubit,
        seed: () => GroupLoaded(group: testGroup),
        act: (cubit) => cubit.join('some other code', testUser),
        expect: () => [
          GroupError(
            error:
                'Invalid invitation. Make sure you have copied the link correctly.',
          )
        ],
        verify: (_) {
          verifyNever(() => groupService.joinGroup(any(), any()));
        },
      );

      blocTest<GroupCubit, GroupState>(
        'emmits error state if the user is already a member of the group',
        build: () => groupCubit,
        seed: () {
          Group testGroup = Group.empty(code: 'qwe123');
          testGroup.addUser(testUser);
          return GroupLoaded(group: testGroup);
        },
        act: (GroupCubit cubit) => cubit.join('qwe123', testUser),
        expect: () =>
            [GroupError(error: 'You are already a member of this group')],
        verify: (_) {
          verifyNever(() => groupService.joinGroup(any(), any()));
        },
      );
    });
  });
}
