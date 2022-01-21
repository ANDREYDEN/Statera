import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/constants.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, signInState) {
        if (signInState is SignInLoading) {
          return PageScaffold(child: Center(child: Loader()));
        }

        final signInCubit = context.read<SignInCubit>();

        return PageScaffold(
          title: kAppName,
          child: Center(
            child: Container(
              width: 500,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 50),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'email',
                        border: OutlineInputBorder(),
                      ),
                      enabled: signInState is! SignInLoading,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      enabled: signInState is! SignInLoading,
                    ),
                    if (signInState is AuthSignUp)
                      Column(
                        children: [
                          SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'repeat password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            enabled: signInState is! SignInLoading,
                          ),
                        ],
                      ),
                    SizedBox(height: 8),
                    if (signInState is AuthSignIn)
                      TextButton(
                        onPressed: () {
                          signInCubit.switchToSignUpState();
                        },
                        child: Text('Register'),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          signInCubit.switchToSignInState();
                        },
                        child: Text('Sign In'),
                      ),
                    ElevatedButton(
                      onPressed: signInState is SignInLoading
                          ? null
                          : () => signInCubit.signIn(
                                _emailController.text,
                                _passwordController.text,
                              ),
                      child: SizedBox(
                        height: 36,
                        child: Center(
                          child: Text(
                            signInState is AuthSignIn ? 'Sign In' : 'Sign Up',
                          ),
                        ),
                      ),
                    ),
                    if (signInState is SignInError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Text(
                            signInState.error,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('or'),
                          ),
                          Expanded(child: Divider())
                        ],
                      ),
                    ),
                    SignInButton(
                      Buttons.Google,
                      onPressed: signInState is SignInLoading
                          ? () {}
                          : () => signInCubit.signInWithGoogle(),
                      elevation: 2,
                      text: signInState is AuthSignIn
                          ? 'Sign in with Google'
                          : 'Sign up with Google',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
