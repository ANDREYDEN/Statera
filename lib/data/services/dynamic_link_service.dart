import 'dart:async';

import 'package:app_links/app_links.dart';

class DynamicLinkService {
  void listen(Function(String path) linkHandler) {
    final appLinks = AppLinks();

    appLinks.uriLinkStream.listen((uri) {
      linkHandler(uri.path);
    });
  }

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

    return 'https://statera-0.web.app$path';
  }
}
