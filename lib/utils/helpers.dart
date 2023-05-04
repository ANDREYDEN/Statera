import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statera/utils/utils.dart';

configureEmulators() async {
  const useEmulators = const bool.fromEnvironment(kEmulatorFlag);
  debugPrint(
    'Talking to Firebase using ${useEmulators ? 'EMULATOR' : 'PRODUCTION'} data',
  );
  if (!useEmulators) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    return;
  };

  final host = 'localhost';
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

  await FirebaseRemoteConfig.instance.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(seconds: 30),
  ));
}

String getRandomLetter() {
  int asciiCode = 97 + Random().nextInt(26);
  return String.fromCharCode(asciiCode);
}

String? toStringDate(DateTime? date) {
  return date == null ? null : DateFormat('d MMM, yyyy').format(date);
}

String? toStringDateTime(DateTime? date) {
  return date == null ? null : DateFormat('d MMM, yyyy h:mm:ss a').format(date);
}

Future<bool> snackbarCatch(
  BuildContext context,
  dynamic Function() operation, {
  String? successMessage,
  String? errorMessage,
}) async {
  bool errorOccured = false;
  try {
    await operation();
  } catch (e) {
    errorOccured = true;
    errorMessage = errorMessage ?? e.toString();
  }

  if (errorOccured || (successMessage != null && successMessage.isNotEmpty)) {
    showSnackBar(
      context,
      errorOccured ? errorMessage! : successMessage!,
      color: errorOccured
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.secondary,
    );
  }

  return !errorOccured;
}

void showSnackBar(
  BuildContext context,
  String content, {
  Duration duration = const Duration(seconds: 3),
  Color? color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      margin: EdgeInsets.all(8),
      backgroundColor: color,
      duration: duration,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

pluralize(term, quantity) {
  var pluralTerm =
      (quantity % 10 == 1 && quantity % 100 != 11) ? term : '${term}s';
  return '$quantity $pluralTerm';
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

isMobilePlatform() {
  return (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) &&
      !kIsWeb;
}

isApplePlatform() {
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

String currentPlatformName =
    kIsWeb ? 'web' : defaultTargetPlatform.toString().split('.')[1];
