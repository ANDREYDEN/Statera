import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:statera/data/services/services.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('DynamicLinkService', () {
    final dynamicLinkService = DynamicLinkService();

    test('can handle null url', () async {
      final testPath = null;

      String url = await dynamicLinkService.generateDynamicLink(path: testPath);

      expect(url, isNotNull);
    });

    test(
      'should create a valid url from path with /',
      () async {
        String testPath = '/groups/invite';

        final link =
            await dynamicLinkService.generateDynamicLink(path: testPath);

        expect(link, endsWith(testPath));
      },
    );

    test(
      'should create a valid url from path without /',
      () async {
        String testPath = 'groups/invite';

        final link =
            await dynamicLinkService.generateDynamicLink(path: testPath);

        expect(link, endsWith('/' + testPath));
      },
    );
  });
}
