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
              child: Column(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'email'),
                      enabled: signInState is! SignInLoading,
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'password'),
                      obscureText: true,
                      enabled: signInState is! SignInLoading,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: signInState is SignInLoading
                        ? null
                        : () => signInCubit.signIn(
                              _emailController.text,
                              _passwordController.text,
                            ),
                    child: Text('Sign In'),
                  ),
                  if (signInState is SignInError)
                    Text(
                      signInState.error,
                      style: TextStyle(color: Colors.red),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  SignInButton(
                    Buttons.Google,
                    onPressed: signInState is SignInLoading
                        ? () {}
                        : () => signInCubit.signInWithGoogle(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
