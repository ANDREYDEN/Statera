# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run all unit & widget tests
flutter test

# Run a single test file
flutter test test/ui/groups/profile_reminder_test.dart

# Run with coverage
flutter test --coverage

# Regenerate mocks after changing a @GenerateNiceMocks annotation
dart run build_runner build

# Run on device with Firebase emulators
derry run-emulate          # prompts for device
derry run-web-emulate      # Chrome

# Lint
flutter analyze
```

To use Firebase emulators locally, run `firebase emulators:start` and pass `--dart-define="MODE=debug"` (which `derry run-emulate` does automatically).

## Architecture

### Entry point & DI

`lib/main.dart` initialises Firebase, then runs `Statera`. The root widget wraps everything in `RepositoryRegistrant` (`lib/repository_registrant.dart`), which uses `MultiRepositoryProvider` to register all services (Firestore repos, file services, auth, notifications, etc.) as plain `Provider` values. A single global `AuthBloc` sits just below that.

### Routing

`lib/ui/routing/pages.dart` defines a `GoRouter` configuration (`CustomRouterConfig`). Routes that require authentication are wrapped in `AuthenticatedGoRoute`, which also injects `NotificationsInitializer`. The auth redirect stream watches `AuthBloc` state. Each route's `builder` calls the page's static `init()` method.

### Page init pattern

Every page that needs BLoC state has a static `init()` method that wraps the page widget in a `MultiBlocProvider`, creating and loading the required cubits from the already-registered repository providers:

```dart
static Widget init() {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => SomeCubit(context.read<SomeRepository>())
          ..load(context.read<AuthBloc>().uid),
      ),
    ],
    child: SomePage(),
  );
}
```

This keeps DI wiring at the route level and out of widget constructors.

### State management

BLoC/Cubit is used throughout. Cubits cover most features (user, groups, expenses list, payments, notifications). `ExpenseBloc` uses the event-driven `Bloc` base class for the single-expense editing flow. UI widgets read state via `BlocBuilder` / `BlocListener` / `context.select`.

### Data layer

All Firestore access goes through repository/service classes in `lib/data/services/`. They extend a `Firestore` base class that provides typed `CollectionReference` getters with `withConverter`. Repositories expose `Stream`s for reactive UI updates and `Future`s for mutations.

