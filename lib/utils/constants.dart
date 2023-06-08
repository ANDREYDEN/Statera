const kAppName = 'Statera';

const kEmulatorFlag = 'MODE';
const kIsModeDebug = String.fromEnvironment(kEmulatorFlag) == 'debug';

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
  'password-mismatch': 'Passwords should match'
};

const kSignInWithGoogleMessages = {
  'user-not-found': 'There is no user associated with this email address',
  'user-disabled': 'This user has been disabled',
};

const kRequiredValidationMessage = "Can't be empty";

const kNotificationsReminderCooldown = Duration(days: 2);