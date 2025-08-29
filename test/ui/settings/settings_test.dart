import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.mocks.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/business_logic/user/user_cubit.mocks.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/color/seed_color_cubit.dart';
import 'package:statera/ui/color/seed_color_cubit.mocks.dart';
import 'package:statera/ui/settings/profile_completion/profile_completion.dart';
import 'package:statera/ui/settings/settings_page.dart';

import '../../helpers.dart';
import 'settings_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HttpClient>()])
@GenerateNiceMocks([MockSpec<HttpClientRequest>()])
@GenerateNiceMocks([MockSpec<HttpClientResponse>()])
@GenerateNiceMocks([MockSpec<HttpOverrides>()])
void main() {
  group('Settings', () {
    late CustomUser userWithIncompleteProfile;
    late CustomUser userWithCompleteProfile;

    setUp(() {
      userWithIncompleteProfile = CustomUser(
        uid: defaultCurrentUserId,
        name: 'Test User',
      );

      userWithCompleteProfile = CustomUser(
        uid: defaultCurrentUserId,
        photoURL: 'https://example.com/photo.jpg',
        name: 'Test User',
        paymentInfo: 'user@example.com',
      );
    });

    testWidgets('shows profile completion banner if there are incomplete items',
        (tester) async {
      mockHttpClient([userWithCompleteProfile.photoURL!]);
      await pumpSettings(tester, user: userWithIncompleteProfile);

      expect(find.byType(ProfileCompletion), findsOneWidget);
    });

    testWidgets(
        'does not show profile completion banner if the profile is complete',
        (tester) async {
      await pumpSettings(tester, user: userWithCompleteProfile);

      expect(find.byType(ProfileCompletion), findsNothing);
      expect(find.text('Profile Information'), findsOneWidget);
    });
  });
}

Future<void> pumpSettings(WidgetTester tester, {CustomUser? user}) async {
  final userCubit = MockUserCubit();
  when(userCubit.state).thenReturn(UserLoaded(user: user ?? CustomUser.fake()));
  final notificationsCubit = MockNotificationsCubit();
  final seedColorCubit = MockSeedColorCubit();
  when(seedColorCubit.state).thenReturn(Colors.yellow);

  await customPump(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>.value(value: userCubit),
        BlocProvider<NotificationsCubit>.value(value: notificationsCubit),
        BlocProvider<SeedColorCubit>.value(value: seedColorCubit),
      ],
      child: SettingsPage(),
    ),
    tester,
  );
  await tester.pumpAndSettle();
}

void mockHttpClient(List<String> endpoints) {
  final response = MockHttpClientResponse();
  when(response.statusCode).thenReturn(HttpStatus.ok);

  final request = MockHttpClientRequest();
  when(request.close())
      .thenAnswer((_) => new Future<HttpClientResponse>.value(response));

  final httpClient = MockHttpClient();
  for (final endpoint in endpoints) {
    final uri = Uri.parse(endpoint);
    when(httpClient.getUrl(uri)).thenAnswer((_) async => Future.value(request));
  }

  final httpOverrides = MockHttpOverrides();
  when(httpOverrides.createHttpClient(any)).thenReturn(httpClient);

  HttpOverrides.global = httpOverrides;
}
