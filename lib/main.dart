import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/custom_theme_builder.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/firebase_options.dart';
import 'package:statera/repository_registrant.dart';
import 'package:statera/ui/custom_layout_builder.dart';
import 'package:statera/ui/routing/pages.dart';
import 'package:statera/utils/utils.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAnalytics.instance;
  await FirebaseRemoteConfig.instance.setDefaults(<String, dynamic>{
    'greeting_message': 'Welcome to Statera!',
    'show_greeting_dialog': false,
    'redirect_debt_feature_flag': true
  });

  configureEmulators();

  final initialDynamicLink = null;
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
    return RepositoryRegistrant(
      firestore: FirebaseFirestore.instance,
      child: BlocProvider(
        create: (context) => AuthBloc(context.read<AuthService>()),
        child: CustomThemeBuilder(
          builder: (lightTheme, darkTheme) {
            return CustomLayoutBuilder(
              child: MaterialApp.router(
                title: kAppName,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.system,
                routerConfig: router,
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
