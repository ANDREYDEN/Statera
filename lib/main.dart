import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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

  Uri? initialLink;
  if (isMobilePlatform()) {
    final dynamicLink = await FirebaseDynamicLinks.instance.getInitialLink();
    initialLink = dynamicLink?.link;
  }

  runApp(Statera(initialLink: initialLink));
}

class Statera extends StatefulWidget {
  final Uri? initialLink;

  const Statera({Key? key, this.initialLink}) : super(key: key);

  @override
  State<Statera> createState() => _StateraState();
}

class _StateraState extends State<Statera> {
  StreamSubscription<PendingDynamicLinkData>? _dynamicLinkSubscription = null;

  @override
  void initState() {
    final initialLink = widget.initialLink;
    if (initialLink != null) {
      Navigator.pushNamed(context, initialLink.path);
    }

    if (isMobilePlatform()) {
      _dynamicLinkSubscription =
          FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
        Navigator.pushNamed(context, dynamicLinkData.link.path);
      })
            ..onError((error) {
              FirebaseCrashlytics.instance.recordFlutterError(error);
            });
    }
    super.initState();
  }

  @override
  void deactivate() {
    _dynamicLinkSubscription?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => FirebaseStorageRepository()),
        RepositoryProvider(create: (_) => DynamicLinkRepository())
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
