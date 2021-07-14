# Statera

An expense tracking app with granular price distribution.

## Set up

### Requirements
- Flutter
- Dart
- `derry` [dart package](https://pub.dev/packages/derry) globally installed
- Android and/or iOS emulator and/or Web for testing
- lcov - for testing with coverage

### Firebase

- Create an iOS/Android app in the Firebase console
- Include your `google-services.json` and `GoogleService-Info.plist` to the proper places as described in the [docs](https://firebase.google.com/docs/flutter/setup?platform=android)

### Commands
- `flutter run` - runs the project
- `derry build` - builds the app and generates mocks for tests
- `derry test` - runs the tests
- `derry test-coverage` - generate a coverage report