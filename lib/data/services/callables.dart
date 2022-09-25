import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/utils/utils.dart';

class Callables {
  static HttpsCallable _getReceiptData =
      FirebaseFunctions.instance.httpsCallable('getReceiptData');

  static HttpsCallable _updateUserNotificationToken =
      FirebaseFunctions.instance.httpsCallable('updateUserNotificationToken');

  static HttpsCallable _notifyWhenExpenseCompleted =
      FirebaseFunctions.instance.httpsCallable('notifyWhenExpenseIsCompleted');

  static HttpsCallable _notifyWhenExpenseFinalized =
      FirebaseFunctions.instance.httpsCallable('notifyWhenExpenseIsFinalized');

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

  static Future<void> notifyWhenExpenseCompleted({required expenseId}) async {
    await _notifyWhenExpenseCompleted({'expenseId': expenseId});
  }

  static Future<void> notifyWhenExpenseFinalized({required expenseId}) async {
    await _notifyWhenExpenseFinalized({'expenseId': expenseId});
  }
}
