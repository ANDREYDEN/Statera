flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots.test.dart \
  --dart-define=MODE=debug \
  --screenshot=./failed_screenshots \
  -d web-server
  --browser-name=chrome