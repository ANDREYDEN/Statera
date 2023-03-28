flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots.test.dart \
  --dart-define=USE_EMULATORS=true \
  --screenshot=./failed_screenshots \
  --keep-app-running \
  -d $1