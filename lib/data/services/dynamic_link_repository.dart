import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkRepository {
  FirebaseDynamicLinks firebaseDynamicLinks;

  DynamicLinkRepository({required this.firebaseDynamicLinks});

  Future<String> generateDynamicLink({
    String? path,
    SocialMetaTagParameters? socialMetaTagParameters,
  }) async {
    path ??= '/';

    if (!path.startsWith('/')) {
      path = '/' + path;
    }

    final parameters = DynamicLinkParameters(
      link: Uri.parse('https://statera-0.web.app$path'),
      uriPrefix: 'https://statera.page.link',
      iosParameters: IOSParameters(
        bundleId: 'com.statera.statera',
        appStoreId: '1609503817',
      ),
      androidParameters: AndroidParameters(
        packageName: 'com.statera.statera',
      ),
      socialMetaTagParameters: socialMetaTagParameters,
    );
    
    final link = await firebaseDynamicLinks.buildShortLink(
      parameters,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    return link.shortUrl.toString();
  }
}
