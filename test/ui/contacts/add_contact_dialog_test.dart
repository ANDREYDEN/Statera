import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/contact_repository.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/services/user_group_repository.mocks.dart';
import 'package:statera/ui/contacts/add_contact_dialog.dart';

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'me');
}

void main() {
  group('AddContactDialog', () {
    const currentUid = 'me';
    final alice = CustomUser.fake(name: 'Alice', uid: 'alice');
    final bob = CustomUser.fake(name: 'Bob', uid: 'bob');
    final currentUser = CustomUser.fake(name: 'Me', uid: currentUid);

    late MockAuthService authService;
    late MockGroupRepository groupRepository;
    late MockUserGroupRepository userGroupRepository;
    late MockContactRepository contactRepository;

    setUp(() {
      authService = MockAuthService();
      final user = MockUser();
      when(user.uid).thenReturn(currentUid);
      when(authService.currentUser).thenReturn(user);

      groupRepository = MockGroupRepository();
      userGroupRepository = MockUserGroupRepository();
      contactRepository = MockContactRepository();

      when(
        userGroupRepository.userGroupsStream(currentUid),
      ).thenAnswer(
        (_) => Stream.value([
          UserGroup(groupId: 'g1', name: 'Group One'),
          UserGroup(groupId: 'g2', name: 'Group Two'),
        ]),
      );

      when(groupRepository.getGroupById('g1')).thenAnswer(
        (_) async => Group(
          id: 'g1',
          name: 'Group One',
          members: [currentUser, alice, bob],
        ),
      );
      when(groupRepository.getGroupById('g2')).thenAnswer(
        (_) async =>
            Group(id: 'g2', name: 'Group Two', members: [currentUser]),
      );

      when(contactRepository.listenForContacts(currentUid)).thenAnswer(
        (_) => Stream.value([
          Contact(uid: bob.uid, name: bob.name, photoURL: bob.photoURL),
        ]),
      );
    });

    testWidgets(
      'lets the user pick a group, then add selected members as contacts',
      (tester) async {
        await pumpAddContactDialog(
          tester,
          authService: authService,
          groupRepository: groupRepository,
          userGroupRepository: userGroupRepository,
          contactRepository: contactRepository,
        );

        expect(find.text('Select a Group'), findsOneWidget);
        expect(find.text('Group One'), findsOneWidget);
        expect(find.text('Group Two'), findsOneWidget);

        await tester.tap(find.text('Group One'));
        await tester.pumpAndSettle();

        expect(find.text('Add Contacts'), findsOneWidget);
        // the current user and existing contact Bob are excluded
        expect(find.text(alice.name), findsOneWidget);
        expect(find.text(bob.name), findsNothing);
        expect(find.text(currentUser.name), findsNothing);

        await tester.tap(find.text(alice.name));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        verify(contactRepository.addContact(currentUid, alice.uid)).called(1);
        expect(find.text('Add Contacts'), findsNothing);
      },
    );

    testWidgets(
      'shows a message when all group members are already contacts',
      (tester) async {
        await pumpAddContactDialog(
          tester,
          authService: authService,
          groupRepository: groupRepository,
          userGroupRepository: userGroupRepository,
          contactRepository: contactRepository,
        );

        await tester.tap(find.text('Group Two'));
        await tester.pumpAndSettle();

        expect(
          find.text('All members of this group are already in your contacts.'),
          findsOneWidget,
        );
      },
    );
  });
}

Future<void> pumpAddContactDialog(
  WidgetTester tester, {
  required AuthService authService,
  required GroupRepository groupRepository,
  required UserGroupRepository userGroupRepository,
  required ContactRepository contactRepository,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authService)),
        Provider<LayoutState>(create: (_) => LayoutState.narrow()),
        Provider<GroupRepository>.value(value: groupRepository),
        Provider<UserGroupRepository>.value(value: userGroupRepository),
        Provider<ContactRepository>.value(value: contactRepository),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AddContactDialog.show(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
