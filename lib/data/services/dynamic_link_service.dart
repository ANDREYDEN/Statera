class DynamicLinkService {
  static String generateDynamicLink({String? path}) {
    path ??= '/';
    
    if (!path.startsWith('/')) {
      path = '/' + path;
    }
    
    return Uri.https(
      'statera.page.link',
      '',
      {
        'apn': 'com.statera.statera',
        'ibi': 'com.statera.statera',
        'link': "https://statera-0.web.app$path",
      },
    ).toString();
  }
}
