import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<ErrorService>()])
class ErrorService {
  Future<void> recordError(Object error, {String? reason}) {
    return FirebaseCrashlytics.instance.recordError(
      error,
      null,
      reason: 'Receipt upload failed',
    );
  }
}
