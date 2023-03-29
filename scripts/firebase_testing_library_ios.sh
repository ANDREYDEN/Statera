output="../build/ios_integ"
product="build/ios_integ/Build/Products"
dev_target="14.3"

# Pass --simulator if building for the simulator.
flutter build ios integration_test/basic_flow.test.dart --release

pushd ios
xcodebuild build-for-testing \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -xcconfig Flutter/Release.xcconfig \
  -configuration Release \
  -derivedDataPath \
  $output -sdk iphoneos
popd

pushd $product
zip -r "ios_tests.zip" "Release-iphoneos" "Runner_iphoneos$dev_target-arm64.xctestrun"
popd