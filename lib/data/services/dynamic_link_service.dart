class DynamicLinkService {
  Future<String> generateDynamicLink({
    String? path,
    String? socialTitle,
    String? socialDescription,
    String? socialImageLink,
  }) async {
    path ??= '/';

    if (!path.startsWith('/')) {
      path = '/' + path;
    }

    return 'https://statera-0.web.app$path';
  }
}
