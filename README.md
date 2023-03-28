# Statera

An expense tracking app with granular price distribution.

![image](https://user-images.githubusercontent.com/25109066/125558203-e66178cd-00da-4e88-b219-09e136576b08.png)
![image](https://user-images.githubusercontent.com/25109066/125557693-e5ae08ab-ad88-4d5b-8480-8bc5e0202a3a.png)


## Set up

### Requirements
- Flutter
- Dart
- `derry` [dart package](https://pub.dev/packages/derry) globally installed - for running custom commands
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) globally installed - for configuring Firebase
- Android and/or iOS emulator and/or Web for testing
- lcov - for testing with coverage

### Firebase

- Create an iOS/Android app in the Firebase console
- Include your `google-services.json` and `GoogleService-Info.plist` to the proper places as described in the [docs](https://firebase.google.com/docs/flutter/setup?platform=android)

### Environment

- A `.env` file is required and must not be empty
- Copy the `.env.example` file and fill in the values

### Commands
- `flutter run` - runs the project
- `flutterfire configure` - initializes the connection between you Firebase project and this Flutter project
- `derry emulate` - runs Firebase emulators fr local development
- `derry test` - runs the tests

Full list of commands can be found in the `pubspec.yaml` file

## Development

## Testing

### Unit & Widget tests

These are fast tests that verify business logic functionality and behaviour of separate widgets.
Unit tests are contained under the `test` directory. 

Run unit tests:
```
flutter test
```

Include coverage report:
```
flutter test --coverage
```

### Integration tests

These tests run on a simulator while talking to an emulator version of Firebase.
Integration tests are contained under the `integration_test` directory while the driver is defined under the `test_driver` directory.

Run integration tests:
1. Start the Firebase emulators
    ```
    firebase emulators:start --import ./emulator_data_testing
    ```
2. Start the test driver
    ```
    ./scripts/take_screenshots.sh
    ```

Currently, there is an issue with [taking screenshots on iOS](https://github.com/flutter/flutter/issues/51890). There exists [a workaround](https://github.com/flutter/flutter/issues/91668#issuecomment-1132381182) and an [open PR](https://github.com/flutter/flutter/pull/116539).

## References & useful links

- icons generated through [Icon Kitchen](https://icon.kitchen)
- Trunk Based Development deployments with GitHub actions [article](https://blog.jannikwempe.com/github-actions-trunk-based-development)