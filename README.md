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
- Run `flutterfire configure` to connect with your Firebase project and get configuration files for your apps

### Environment

- A `.env` file is required and must not be empty
- Copy the `.env.example` file and fill in the values

### Commands
- `derry emulate` - runs Firebase emulators fr local development
- `derry test` - runs the tests

Full list of commands can be found in the `pubspec.yaml` file

## Development

## Deployment

This project uses Fastlane for deployment to App Store and Play Store

### Screenshots

**iOS**
- `cd ios`
- `fastlane snapshot`

## References & useful links

- icons generated through [Icon Kitchen](https://icon.kitchen)