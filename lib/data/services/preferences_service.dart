import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<bool> checkGreetingMessageSeen(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final messageHashes = prefs.getStringList('viewed_greeting_message_hashes');
    return messageHashes?.contains(message.hashCode.toString()) ?? false;
  }

  Future<void> recordGreetingMessageSeen(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final messageHashes = prefs.getStringList('viewed_greeting_message_hashes');
    final newMessageHashes = [...?messageHashes, message.hashCode.toString()];
    await prefs.setStringList(
      'viewed_greeting_message_hashes',
      newMessageHashes,
    );
  }

  Future<bool> checkNotificationsReminderShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_reminder_shown') ?? false;
  }

  Future<void> recordNotificationsReminderShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_reminder_shown', true);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
