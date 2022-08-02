import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:statera/firebase_options.dart';

class DynamicLinkRepository {
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

    final uri = Uri(
      scheme: 'https',
      host: 'firebasedynamiclinks.googleapis.com',
      path: 'v1/shortLinks',
      queryParameters: {'key': DefaultFirebaseOptions.currentPlatform.apiKey},
    );

    final client = http.Client();
    final response = await client.post(
      uri,
      body: json.encode({
        'suffix': {
          'option': 'UNGUESSABLE',
        },
        'dynamicLinkInfo': {
          'domainUriPrefix': 'https://statera.page.link',
          'link': 'https://statera-0.web.app$path',
          'androidInfo': {
            'androidPackageName': 'com.statera.statera',
          },
          'iosInfo': {
            'iosBundleId': 'com.statera.statera',
            'iosAppStoreId': '1609503817'
          },
          'socialMetaTagInfo': {
            if (socialTitle != null) 'socialTitle': socialTitle,
            if (socialDescription != null)
              'socialDescription': socialDescription,
            if (socialImageLink != null) 'socialImageLink': socialImageLink
          }
        }
      }),
    );

    print('Attempted to create dynamic link: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw Exception(
          'Something went wrong while creating a dynamic link: ${response.body}');
    }

    return json.decode(response.body)['shortLink'];
  }
}
