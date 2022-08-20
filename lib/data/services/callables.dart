import 'package:cloud_functions/cloud_functions.dart';
import 'package:statera/data/models/models.dart';

class Callables {
  static HttpsCallable _getReceiptData =
      FirebaseFunctions.instance.httpsCallable('getReceiptData');

  static HttpsCallable _updateUserNotificationToken =
      FirebaseFunctions.instance.httpsCallable('updateUserNotificationToken');

  static HttpsCallable _notifyWhenExpenseCompleted = FirebaseFunctions
      .instance
      .httpsCallable('notifyWhenExpenseIsCompleted');

  static Future<List<Item>> getReceiptData({
    required String receiptUrl,
    required String selectedStore,
    required bool withNameImprovement,
  }) async {
    var response = await _getReceiptData({
      'receiptUrl': receiptUrl,
      'storeName': selectedStore,
      'withNameImprovement': withNameImprovement
    });

    return (response.data as List<dynamic>).map((itemData) {
      final value = double.tryParse(itemData['value'].toString()) ?? 0;
      final quantity = int.tryParse(itemData['quantity'].toString()) ?? 1;
      return Item(
        name: itemData['name'] ?? 'item',
        value: value,
        partition: quantity,
      );
    }).toList();
  }

  static Future<void> updateUserNotificationToken({
    required String uid,
    required String token,
  }) async {
    await _updateUserNotificationToken({'uid': uid, 'token': token});
  }

  static Future<void> notifyWhenExpenseCompleted({
    required expenseId,
  }) async {
    await _notifyWhenExpenseCompleted({'expenseId': expenseId});
  }
}
