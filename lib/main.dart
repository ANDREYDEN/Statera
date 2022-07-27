import 'package:firebase_core/firebase_core.dart';
import 'package:statera/firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/landing/landing_page.dart';
import 'package:statera/ui/routing/pages.dart';
import 'package:statera/utils/utils.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  configureEmulators();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(Statera());
}

class Statera extends StatelessWidget {
  const Statera({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => FirebaseStorageRepository()),
      ],
      child: BlocProvider(
        create: (context) {
          final authRepository = context.read<AuthRepository>();
          return AuthBloc(authRepository);
        },
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
                initialRoute: kIsWeb ? LandingPage.route : GroupList.route,
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
