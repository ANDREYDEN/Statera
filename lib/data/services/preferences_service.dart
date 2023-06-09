import 'package:shared_preferences/shared_preferences.dart';
import 'package:statera/utils/utils.dart';

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
    final lastTimestamp = prefs.getInt('notifications_reminder_shown_at');
    if (lastTimestamp == null) return false;

    final lastShown = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
    final now = DateTime.now();

    return now.difference(lastShown) < kNotificationsReminderCooldown;
  }

  Future<void> recordNotificationsReminderShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'notifications_reminder_shown_at',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
