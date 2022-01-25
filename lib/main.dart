import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/firebase_options.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/routing/pages.dart';
import 'package:statera/utils/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  configureEmulators();

  runApp(Statera(authRepository: AuthRepository()));
}

class Statera extends StatelessWidget {
  final AuthRepository authRepository;

  const Statera({Key? key, required this.authRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider(
        create: (context) => AuthBloc(authRepository),
        child: MaterialApp(
          title: kAppName,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          onGenerateRoute: onGenerateRoute,
          initialRoute: GroupList.route,
        ),
      ),
    );
  }
}
