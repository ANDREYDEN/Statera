import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  TextEditingController _passwordConfirmController = TextEditingController();
  bool _isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, signInState) {
        final signInCubit = context.read<SignInCubit>();

        return PageScaffold(
          title: kAppName,
          child: Center(
            child: Container(
              width: 500,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: ListView(
                  children: [
                    SizedBox(height: 50),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      enabled: signInState is! SignInLoading,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      enabled: signInState is! SignInLoading,
                    ),
                    if (!_isSignIn)
                      Column(
                        children: [
                          SizedBox(height: 8),
                          TextField(
                            controller: _passwordConfirmController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            enabled: signInState is! SignInLoading,
                          ),
                        ],
                      ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: signInState is SignInLoading
                          ? null
                          : _isSignIn
                              ? () => signInCubit.signIn(
                                    _emailController.text,
                                    _passwordController.text,
                                  )
                              : () => signInCubit.signUp(
                                    _emailController.text,
                                    _passwordController.text,
                                    _passwordConfirmController.text,
                                  ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9.0),
                        child: Center(
                          child: signInState is SignInLoading
                              ? Loader()
                              : Text(_isSignIn ? 'Sign In' : 'Sign Up'),
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
                    // TODO: Add Google icon
                    ElevatedButton(
                      onPressed: signInState is SignInLoading
                          ? null
                          : () => signInCubit.signInWithGoogle(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9.0),
                        child: Center(
                          child: signInState is SignInLoading
                              ? Loader()
                              : Text(_isSignIn
                                  ? 'Sign in with Google'
                                  : 'Sign up with Google'),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    if (Platform.isIOS)
                      ElevatedButton(
                        onPressed: signInState is SignInLoading
                            ? null
                            : () => signInCubit.signInWithApple(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9.0),
                          child: Center(
                            child: signInState is SignInLoading
                                ? Loader()
                                : Text(_isSignIn
                                    ? 'Sign in with Apple'
                                    : 'Sign up with Apple'),
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignIn = !_isSignIn;
                        });
                      },
                      child: Text(_isSignIn
                          ? 'Create an account'
                          : 'Already have an account?'),
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
