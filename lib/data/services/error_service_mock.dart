import 'package:statera/data/services/error_service.dart';

class MockErrorService implements ErrorService {
  static void registerGlobalErrorListeners() {
    // No-op
  }

  Future<void> recordError(Object error, {String? reason}) async {
    print(
      'MockErrorService: recordError called with reason: "$reason", error:',
    );
    print(error);
  }
}
