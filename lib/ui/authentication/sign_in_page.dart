import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/business_logic/sign_in/sign_in_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/platform_context.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/utils.dart';

class SignInPage extends StatefulWidget {
  static const String name = 'SignIn';

  final String? destinationPath;
  const SignInPage({Key? key, this.destinationPath}) : super(key: key);

  static Widget init({required String? destinationPath}) {
    return BlocProvider(
      create: (context) => SignInCubit(context.read<AuthService>()),
      child: SignInPage(destinationPath: destinationPath),
    );
  }

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  bool _isSignIn = true;

  Future<void> _handleSubmit() async {
    final signInCubit = context.read<SignInCubit>();
    if (_isSignIn) {
      await signInCubit.signIn(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      await signInCubit.signUp(
        _emailController.text,
        _passwordController.text,
        _passwordConfirmController.text,
      );
    }

    context.replace(widget.destinationPath ?? '/groups');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, signInState) {
        final signInCubit = context.read<SignInCubit>();
        final platformContext = context.read<PlatformContext>();

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
                      onPressed:
                          signInState is SignInLoading ? null : _handleSubmit,
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
                    if (platformContext.isWeb ||
                        platformContext.isMobile ||
                        platformContext.isWindows)
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
                    if (platformContext.isApple)
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
                      onPressed: signInState is SignInLoading
                          ? null
                          : () {
                              setState(() {
                                _isSignIn = !_isSignIn;
                              });
                            },
                      child: Text(_isSignIn
                          ? 'Create an account'
                          : 'Already have an account?'),
                    )
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
