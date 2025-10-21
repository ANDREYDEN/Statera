import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ErrorService {
  static void registerGlobalErrorListeners() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Future<void> recordError(Object error, {String? reason}) {
    return FirebaseCrashlytics.instance.recordError(
      error,
      StackTrace.current,
      reason: reason ?? 'Unknown error',
    );
  }
}
