import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/firebase_options.dart';
import 'package:statera/ui/landing/landing_page.dart';
import 'package:statera/ui/routing/pages.dart';
import 'package:statera/utils/utils.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAnalytics.instance;
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
                initialRoute: LandingPage.route,
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
