import 'package:cloud_functions/cloud_functions.dart';
import 'package:statera/data/models/models.dart';

class Callables {
  static HttpsCallable _getReceiptData =
      FirebaseFunctions.instance.httpsCallable('getReceiptData');

  HttpsCallable _updateUserNotificationToken =
      FirebaseFunctions.instance.httpsCallable('updateUserNotificationToken');

  static Future<List<Item>> getReceiptData({
    required String receiptUrl,
    required bool isWalmart,
    required bool withNameImprovement,
  }) async {
    var response = await _getReceiptData({
      'receiptUrl': receiptUrl,
      'isWalmart': isWalmart,
      'withNameImprovement': withNameImprovement
    });

    return (response.data as List<dynamic>).map((itemData) {
      return Item(
        name: itemData["name"] ?? "item",
        value: double.tryParse(itemData["value"].toString()) ?? 0,
      );
    }).toList();
  }
}
