import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mockito/annotations.dart';

/// This is a wrapper around Firebase Remote Config, it provides better API for accessing feature flags.
/// This service is also auto mocked for testing.
@GenerateNiceMocks([MockSpec<FeatureService>()])
class FeatureService {
  bool get useDynamicExpenseLoading => FirebaseRemoteConfig.instance
        .getBool('dynamic_expense_loading_feature_flag');
}