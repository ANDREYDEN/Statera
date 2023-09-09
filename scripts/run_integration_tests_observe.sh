flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/e2e.test.dart \
  --dart-define=MODE=debug \
  --dart-define=CHECK_NOTIFICATIONS=false \
  -d web-server \
  --browser-name=chrome \
  --no-headless \
  --keep-app-running