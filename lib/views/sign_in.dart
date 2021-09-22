import 'package:flutter/material.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/utils/constants.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/widgets/page_scaffold.dart';

class SignIn extends StatefulWidget {
  static String route = 'sign-in';
  final String? error;
  final String forwardRoute;

  const SignIn({
    Key? key,
    this.error,
    this.forwardRoute = '/',
  }) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _loading = false;

  @override
  void initState() {
    if (widget.error != null) {
      showSnackBar(context, widget.error!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: kAppName,
      child: Center(
        child: _loading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  var signInSuccess = await snackbarCatch(context, () async {
                    setState(() {
                      _loading = true;
                    });
                    await Auth.instance.signInWithGoogle();
                    Navigator.of(context).pushNamed(widget.forwardRoute);
                  });

                  setState(() {
                    _loading = signInSuccess;
                  });
                },
                child: Text("Log In with Google"),
              ),
      ),
    );
  }
}
