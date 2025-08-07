import 'package:statera/data/services/error_service.dart';

class ErrorServiceMock implements ErrorService {
  static void registerGlobalErrorListeners() {
    // No-op
  }

  Future<void> recordError(Object error, {String? reason}) async {
    // No-op
  }
}
