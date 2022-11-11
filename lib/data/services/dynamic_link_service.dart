import 'dart:async';
import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:statera/firebase_options.dart';

class DynamicLinkService {
  Future<StreamSubscription<PendingDynamicLinkData>> listen(
    BuildContext context,
  ) async {
    return FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      navigateToPath(context, dynamicLinkData.link.path);
    })
      ..onError((error) {
        FirebaseCrashlytics.instance.recordFlutterError(error);
      });
  }

  void navigateToPath(BuildContext context, String path) {
    final currentPath = ModalRoute.of(context)?.settings.name;
    if (path != currentPath) {
      Navigator.pushNamed(context, path);
    }
  }

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

    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw Exception(
        'Something went wrong while creating a dynamic link: ${response.body}',
      );
    }

    return json.decode(response.body)['shortLink'];
  }
}
