import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/services/dynamic_link_service.dart';

void main() {
  group('DynamicLinkService', () {
    test('can handle null url', () {
      final testPath = null;

      String url = DynamicLinkService.generateDynamicLink(path: testPath);
      final uri = Uri.parse(url);
      final forwardUrl = uri.queryParameters['link'];

      expect(forwardUrl, isNotNull);

      final forwardUri = Uri.parse(forwardUrl!);
      final actualPath = forwardUri.path;

      expect(actualPath, equals('/'));
    });

    test('should create a valid url from path without /', () {
      String testPath = 'groups/invite';

      String url = DynamicLinkService.generateDynamicLink(path: testPath);
      final uri = Uri.parse(url);
      final forwardUrl = uri.queryParameters['link'];

      expect(forwardUrl, isNotNull);

      final forwardUri = Uri.parse(forwardUrl!);
      final actualPath = forwardUri.path;

      expect(actualPath, equals('/' + testPath));
    });

    test('should create a valid url from path with /', () {
      String testPath = 'groups/invite';

      String url = DynamicLinkService.generateDynamicLink(path: '/' + testPath);
      final uri = Uri.parse(url);
      final forwardUrl = uri.queryParameters['link'];

      expect(forwardUrl, isNotNull);

      final forwardUri = Uri.parse(forwardUrl!);
      final actualPath = forwardUri.path;

      expect(actualPath, equals('/' + testPath));
    });
  });
}
