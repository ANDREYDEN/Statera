import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/authentication/sign_in_page.dart';

import '../../../integration_test/test_helpers.dart';

class MockSignInCubit extends MockCubit<SignInState> implements SignInCubit {
  MockSignInCubit() : super();
}

class MockAuthRepository extends Mock implements AuthService {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeSignInLoaded extends Fake implements SignInLoaded {}

final userCredential = MockUserCredential();

void main() {
  group('Sign In', () {
    late MockSignInCubit signInCubit;

    setUpAll(() {
      registerFallbackValue(FakeSignInLoaded());
    });

    setUp(() {
      signInCubit = MockSignInCubit();
      when(() => signInCubit.state).thenReturn(SignInLoaded());
      when(
        () => signInCubit.signIn(any(), any()),
      ).thenAnswer((_) async => userCredential);
      when(
        () => signInCubit.signUp(any(), any(), any(), any()),
      ).thenAnswer((_) async => userCredential);
      when(
        () => signInCubit.signInWithGoogle(),
      ).thenAnswer((_) async => userCredential);
      when(
        () => signInCubit.signInWithApple(),
      ).thenAnswer((_) async => userCredential);
    });

    Future<void> buildSignIn(WidgetTester tester) {
      return pumpPage(SignInPage(), tester, signInCubit: signInCubit);
    }

    testWidgets('loads into the sign in state', (WidgetTester tester) async {
      await buildSignIn(tester);

      var signInFinder = find.text('Sign In');
      var signUpFinder = find.text('Sign Up');

      expect(signInFinder, findsOneWidget);
      expect(signUpFinder, findsNothing);
    });

    testWidgets('clicking Sign In calls the signIn method', (
      WidgetTester tester,
    ) async {
      await buildSignIn(tester);

      var signInButton = find.text('Sign In');
      await tester.tap(signInButton);

      verify(() => signInCubit.signIn(any(), any())).called(1);
    });

    testWidgets('can switch to the sign up state', (WidgetTester tester) async {
      await buildSignIn(tester);

      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();

      var signInFinder = find.text('Sign In');
      var signUpFinder = find.text('Sign Up');

      expect(signUpFinder, findsOneWidget);
      expect(signInFinder, findsNothing);
    });

    testWidgets('clicking Sign In calls the signIn method', (
      WidgetTester tester,
    ) async {
      await buildSignIn(tester);
      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();

      var signUpButton = find.text('Sign Up');

      await tester.tap(signUpButton);

      verify(() => signInCubit.signUp(any(), any(), any(), any())).called(1);
    });

    testWidgets(
      'clicking Google sign in button calls the signInWithGoogle method',
      (WidgetTester tester) async {
        await buildSignIn(tester);

        var googleSignInButton = find.bySemanticsLabel('google icon');
        await tester.tap(googleSignInButton);

        verify(() => signInCubit.signInWithGoogle()).called(1);
      },
    );
  });
}
