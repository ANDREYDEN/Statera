import 'dart:async';

import 'package:statera/utils/utils.dart';

class DynamicLinkService {
  Future<String> generateDynamicLink({
    String? path,
    String? socialTitle,
    String? socialDescription,
    String? socialImageLink,
  }) async {
    // TODO: bring back social media features
    path ??= '/';

    if (!path.startsWith('/')) {
      path = '/' + path;
    }

    final base = kIsModeDebug ? '127.0.0.1' : 'https://statera-0.web.app';
    return '$base$path';
  }
}
