import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/services/user_repository.mocks.dart';

void main() {
  group('GroupCubit', () {
    late GroupCubit groupCubit;
    late GroupRepository groupService;
    late ExpenseService expenseService;
    late UserRepository userRepository;
    final String testUserId = 'qwe145';
    final CustomUser testUser = CustomUser(uid: testUserId, name: 'Foo');
    final String testCode = 'qweqwe321';
    final Group testGroup = Group.empty(code: testCode);

    setUp(() {
      groupService = MockGroupRepository();
      expenseService = MockExpenseService();
      userRepository = MockUserRepository();
      groupCubit = GroupCubit(groupService, expenseService, userRepository);
      when(groupService.groupStream(testGroup.id))
          .thenAnswer((_) => Stream.fromIterable([testGroup]));
      when(groupService.addMember(testGroup.code!, testUser))
          .thenAnswer((_) async => testGroup);
      when(userRepository.getUser(testUserId))
          .thenAnswer((realInvocation) async => testUser);
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
        verify(groupService.groupStream(testGroup.id)).called(1);
      },
    );

    group('when joining', () {
      blocTest<GroupCubit, GroupState>(
        'can successfully join a group',
        build: () => groupCubit,
        seed: () => GroupLoaded(group: testGroup),
        act: (cubit) => cubit.addMember(testCode, testUserId),
        expect: () => [GroupLoading(), GroupJoinSuccess(group: testGroup)],
        verify: (_) {
          verify(groupService.addMember(testCode, testUser)).called(1);
        },
      );

      blocTest<GroupCubit, GroupState>(
        'emmits an error state if the code does not match the group code',
        build: () => groupCubit,
        seed: () => GroupLoaded(group: testGroup),
        act: (cubit) => cubit.addMember('some other code', testUserId),
        expect: () => [
          GroupError(
            error:
                'Invalid invitation. Make sure you have copied the link correctly.',
          )
        ],
        verify: (_) {
          verifyNever(groupService.addMember(testGroup.code!, testUser));
        },
      );

      blocTest<GroupCubit, GroupState>(
        'emmits error state if the user is already a member of the group',
        build: () => groupCubit,
        seed: () {
          Group testGroup = Group.empty(code: 'qwe123');
          testGroup.addMember(CustomUser(uid: testUserId, name: 'Foo'));
          return GroupLoaded(group: testGroup);
        },
        act: (GroupCubit cubit) => cubit.addMember('qwe123', testUserId),
        expect: () =>
            [GroupError(error: 'You are already a member of this group')],
        verify: (_) {
          verifyNever(groupService.addMember(testGroup.code!, testUser));
        },
      );
    });
  });
}
