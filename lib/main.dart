import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/firebase_options.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/routing/pages.dart';
import 'package:statera/utils/utils.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Provider<LayoutState>.value(
              value: LayoutState(constraints),
              child: MaterialApp(
                title: kAppName,
                theme: theme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.system,
                onGenerateRoute: onGenerateRoute,
                initialRoute: GroupList.route,
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
