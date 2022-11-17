import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:statera/data/services/services.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('DynamicLinkService', () {
    final dynamicLinkRepository = DynamicLinkService();
    final mockHttpClient = MockHttpClient();

    setUpAll(() {
      registerFallbackValue(Uri.parse('https://example.com'));
      when(() => mockHttpClient.post(any(), body: any(named: 'body')))
          .thenAnswer((invocation) async =>
              Future.value(http.Response('{ "shortLink": "foo" }', 200)));
    });

    test('can handle null url', () async {
      final testPath = null;

      String url =
          await dynamicLinkRepository.generateDynamicLink(path: testPath);

      expect(url, isNotNull);
    });

    test(
      'should create a valid url from path with /',
      () async {
        String testPath = '/groups/invite';

        await dynamicLinkRepository.generateDynamicLink(path: testPath);

        final link = verify(() =>
                mockHttpClient.post(any(), body: captureAny(named: 'body')))
            .captured
            .first['dynamicLinkInfo']['link'];
        expect(link.path, endsWith('/' + testPath));
      },
      skip: true,
    );

    test(
      'should create a valid url from path without /',
      () async {
        String testPath = 'groups/invite';

        await dynamicLinkRepository.generateDynamicLink(path: testPath);

        final link = verify(() =>
                mockHttpClient.post(any(), body: captureAny(named: 'body')))
            .captured
            .first['dynamicLinkInfo']['link'];
        expect(link.path, endsWith('/' + testPath));
      },
      skip: true,
    );
  });
}
