import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/error_service_mock.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/authentication/sign_in_page.dart';

import '../../helpers.dart';
import '../../widget_tester_extensions.dart';

class MockUserCredential extends Mock implements UserCredential {}

final userCredential = MockUserCredential();

void main() {
  group('Sign In', () {
    final uid = 'testUid';
    final authDisplayName = 'John Doe';
    final firestore = FakeFirebaseFirestore();
    final userRepository = UserRepository(firestore);
    final authService = MockAuthService();

    setUp(() {
      final mockUser = MockUser();

      when(mockUser.uid).thenReturn(uid);
      when(mockUser.displayName).thenReturn(authDisplayName);
      when(userCredential.user).thenReturn(mockUser);
      when(
        authService.signUp(any, any),
      ).thenAnswer((_) async => userCredential);
      when(
        authService.signInWithGoogle(),
      ).thenAnswer((_) async => userCredential);
    });

    Future<void> pumpSignInPage(WidgetTester tester) {
      return customPump(
        SignInPage(),
        tester,
        authService: authService,
        extraProviders: [
          BlocProvider<SignInCubit>(
            create: (_) =>
                SignInCubit(authService, MockErrorService(), userRepository),
          ),
        ],
      );
    }

    testWidgets('loads into the sign in state', (WidgetTester tester) async {
      await pumpSignInPage(tester);

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsNothing);
    });

    testWidgets('clicking Sign In authenticates user', (
      WidgetTester tester,
    ) async {
      final email = 'john@example.com';
      final password = 'Qweqwe1!';
      await pumpSignInPage(tester);

      await tester.enterTextByLabel('Email', email);
      await tester.enterTextByLabel('Password', password);

      var signInButton = find.text('Sign In');
      await tester.tap(signInButton);

      verify(authService.signIn(email, password)).called(1);
    });

    testWidgets('can switch to the sign up state', (WidgetTester tester) async {
      await pumpSignInPage(tester);

      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('clicking Sign Up creates and authenticates user', (
      WidgetTester tester,
    ) async {
      final name = 'John Doe';
      final email = 'john@example.com';
      final password = 'Qweqwe1!';
      await pumpSignInPage(tester);

      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();

      await tester.enterTextByLabel('Name', name);
      await tester.enterTextByLabel('Email', email);
      await tester.enterTextByLabel('Password', password);
      await tester.enterTextByLabel('Confirm Password', password);

      var signUpButton = find.text('Sign Up');

      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      final userDoc = await userRepository.usersCollection.doc(uid).get();
      expect(userDoc.exists, isTrue);
      final userData = userDoc.data() as Map<String, dynamic>?;
      expect(userData?['name'], authDisplayName);

      verify(authService.signUp(any, any)).called(1);
    });

    group('sign in with Google', () {
      testWidgets('creates and authenticates user if it does not exist', (
        WidgetTester tester,
      ) async {
        await pumpSignInPage(tester);
        await tester.pumpAndSettle();

        var googleSignInButton = find.bySemanticsLabel('google icon');
        await tester.tap(googleSignInButton);
        await tester.pumpAndSettle();

        final userDoc = await userRepository.usersCollection.doc(uid).get();
        expect(userDoc.exists, isTrue);
        final userData = userDoc.data() as Map<String, dynamic>?;
        expect(userData?['name'], authDisplayName);

        verify(authService.signInWithGoogle()).called(1);
      });

      testWidgets('does not override the user if it already exists', (
        WidgetTester tester,
      ) async {
        final existingName = 'Existing User';
        await firestore.collection('users').doc(uid).set({
          'name': existingName,
        });
        await pumpSignInPage(tester);
        await tester.pumpAndSettle();

        var googleSignInButton = find.bySemanticsLabel('google icon');
        await tester.tap(googleSignInButton);
        await tester.pumpAndSettle();

        final userDoc = await userRepository.usersCollection.doc(uid).get();
        expect(userDoc.exists, isTrue);
        final userData = userDoc.data() as Map<String, dynamic>?;
        expect(userData?['name'], existingName);

        verify(authService.signInWithGoogle()).called(1);
      });
    });
  });
}
