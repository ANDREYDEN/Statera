import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/firebase_options.dart';
import 'package:statera/repository_registrant.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/landing/landing_page.dart';
import 'package:statera/ui/routing/pages.dart';
import 'package:statera/utils/utils.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAnalytics.instance;

  configureEmulators();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  final initialDynamicLink = isMobilePlatform()
      ? await FirebaseDynamicLinks.instance.getInitialLink()
      : null;
  final dynamicLinkPath = initialDynamicLink?.link.path;
  final initialNotificationMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  final notificationPath = AppLaunchHandler.getPath(initialNotificationMessage);

  runApp(Statera(
    initialRoute: dynamicLinkPath ?? notificationPath,
  ));
}

class Statera extends StatelessWidget {
  final String? initialRoute;

  const Statera({Key? key, this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultRoute = kIsWeb
        ? LandingPage.route
        // see https://api.flutter.dev/flutter/material/MaterialApp/initialRoute.html for explanation
        : GroupList.route.replaceFirst('/', '');

    return RepositoryRegistrant(
      child: BlocProvider(
        create: (context) => AuthBloc(context.read<AuthService>()),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Provider<LayoutState>.value(
              value: LayoutState(constraints),
              child: DynamicColorBuilder(
                builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                  ColorScheme lightColorScheme;
                  ColorScheme darkColorScheme;

                  if (lightDynamic != null && darkDynamic != null) {
                    lightColorScheme = lightDynamic.harmonized();
                    darkColorScheme = darkDynamic.harmonized();
                  } else {
                    lightColorScheme = ColorScheme.fromSeed(
                      seedColor: Colors.white,
                    );
                    darkColorScheme = ColorScheme.fromSeed(
                      seedColor: Colors.black,
                      brightness: Brightness.dark,
                    );
                  }

                  return MaterialApp(
                    title: kAppName,
                    theme: buildTheme(lightColorScheme),
                    darkTheme: buildTheme(darkColorScheme),
                    themeMode: ThemeMode.system,
                    initialRoute: initialRoute ?? defaultRoute,
                    onGenerateRoute: onGenerateRoute,
                    debugShowCheckedModeBanner: false,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
