import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/business_logic/user/user_cubit.mocks.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/services/error_service.dart';
import 'package:statera/data/services/error_service_mock.dart';
import 'package:statera/data/services/file_services/file_picker_service.dart';
import 'package:statera/data/services/file_services/file_picker_service.mocks.dart';
import 'package:statera/data/services/file_services/file_storage_service.dart';
import 'package:statera/data/services/file_services/file_storage_service.mocks.dart';
import 'package:statera/ui/groups/profile_reminder.dart';

import '../../helpers.dart';

void main() {
  group('ProfileReminder', () {
    testWidgets(
      'shows the profile update modal if the user\'s username is not set',
      (tester) async {
        await pumpProfileReminder(tester, name: 'anonymous');
        await tester.pumpAndSettle();

        expect(find.text('Complete your profile'), findsOneWidget);
      },
    );

    testWidgets(
      'does not show the profile update modal if the user\'s username is set',
      (tester) async {
        await pumpProfileReminder(tester, name: 'Alice');
        await tester.pumpAndSettle();

        expect(find.text('Complete your profile'), findsNothing);
      },
    );

    testWidgets(
      'does not allow updating username to an empty value',
      (tester) async {
        final userCubit = await pumpProfileReminder(tester, name: 'anonymous');
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), '');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        verifyNever(userCubit.updateName(any, any));
      },
    );

    testWidgets(
      'does not allow updating username to "anonymous"',
      (tester) async {
        final userCubit = await pumpProfileReminder(tester, name: 'anonymous');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid name'), findsOneWidget);
        verifyNever(userCubit.updateName(any, any));
      },
    );

    testWidgets(
      'saves the user\'s name when it is correctly set',
      (tester) async {
        final userCubit = await pumpProfileReminder(tester, name: 'anonymous');
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), 'Alice');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        verify(userCubit.updateName(defaultCurrentUserId, 'Alice')).called(1);
      },
    );
  });
}

Future<MockUserCubit> pumpProfileReminder(
  WidgetTester tester, {
  required String name,
}) async {
  final user = CustomUser(uid: defaultCurrentUserId, name: name);
  final userCubit = MockUserCubit();
  when(userCubit.stream).thenAnswer((_) => Stream.value(UserLoaded(user: user)));

  await customPump(
    ProfileReminder(child: const SizedBox()),
    tester,
    extraProviders: [
      BlocProvider<UserCubit>.value(value: userCubit),
      Provider<FilePickerService>(create: (_) => MockFilePickerService()),
      Provider<FileStorageService>(create: (_) => MockFileStorageService()),
      Provider<ErrorService>(create: (_) => MockErrorService()),
    ],
  );

  return userCubit;
}
