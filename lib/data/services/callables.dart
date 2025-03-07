import 'package:cloud_functions/cloud_functions.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/dtos/version.dart';
import 'package:statera/data/models/models.dart';

@GenerateNiceMocks([MockSpec<Callables>()])
class Callables {
  static HttpsCallable _getReceiptData =
      FirebaseFunctions.instance.httpsCallable('getReceiptData');

  static HttpsCallable _getLatestVersion =
      FirebaseFunctions.instance.httpsCallable('getLatestAppVersion');

  Future<List<Item>> getReceiptData({
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
      return SimpleItem(
        name: itemData['name'] ?? 'item',
        value: value,
        partition: quantity,
      );
    }).toList();
  }

  static Future<Version> getLatestAndroidVersion() async {
    var response = await _getLatestVersion({'platform': 'android'});
    return Version.fromString(response.data);
  }

  static Future<Version> getLatestIOSVersion() async {
    var response = await _getLatestVersion({'platform': 'ios'});
    return Version.fromString(response.data);
  }
}
