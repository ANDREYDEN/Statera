import 'package:flutter/material.dart';

const kAppName = 'Statera';

const kEmulatorFlag = 'MODE';
const kCheckNotificationsFlag = 'CHECK_NOTIFICATIONS';
const kIsModeDebug = String.fromEnvironment(kEmulatorFlag) == 'debug';
const kCheckNotifications = bool.fromEnvironment(
  kCheckNotificationsFlag,
  defaultValue: true,
);

const kSignInMessages = {
  'user-not-found': 'There is no user associated with this email address',
  'invalid-email': 'The provided email is not valid',
  'user-disabled': 'This user has been disabled',
  'wrong-password': 'Invalid credentials',
};

const kSignUpMessages = {
  'email-already-in-use': 'Someone is already signed in with this email',
  'invalid-email': 'The provided email is not valid',
  'operation-not-allowed': 'This user has been disabled',
  'weak-password': 'Your password is not strong enough',
  'password-mismatch': 'Passwords should match',
  'missing-display-name': 'Name should not be empty',
};

const kFirebaseAuthErrorMessages = {
  'user-not-found': 'There is no user associated with this email address',
  'user-disabled': 'This user has been disabled',
};

const kRequiredValidationMessage = "Can't be empty";

const kUpdateBannerRefreshFrequency = Duration(hours: 1);

const kNotificationsReminderCooldown = Duration(days: 30);

const kMobileMargin = EdgeInsets.symmetric(horizontal: 10.0);

const kWideMargin = EdgeInsets.symmetric(horizontal: 50.0);

const kRedirectDebtIcon = Icons.bolt;

const kExpenseUpdateDelay = Duration(milliseconds: 1500);
