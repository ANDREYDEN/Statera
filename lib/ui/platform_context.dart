import 'package:flutter/foundation.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<PlatformContext>()])
class PlatformContext {
  bool get isWeb => kIsWeb;

  bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;
  bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  bool get isMobile => isIOS || isAndroid;
  bool get isApple => isIOS || isMacOS;
}
