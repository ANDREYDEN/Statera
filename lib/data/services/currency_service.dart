import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/value_objects/exchange_rates.dart';

@GenerateNiceMocks([MockSpec<CurrencyService>()])
class CurrencyService extends Firestore {
  static const latestRatesDocId = 'latest';

  Future<ExchangeRates>? _latestRates;

  CurrencyService(FirebaseFirestore firestoreInstance)
    : super(firestoreInstance);

  /// Reads `currencies/latest` once per app session.
  ///
  /// Rates only change daily, so the result is cached. A failed read is not
  /// cached, so the next call retries.
  Future<ExchangeRates> getLatestRates() {
    return _latestRates ??= _fetchLatestRates().catchError((Object error) {
      _latestRates = null;
      throw error;
    });
  }

  Future<ExchangeRates> _fetchLatestRates() async {
    final doc = await currenciesCollection.doc(latestRatesDocId).get();
    final data = doc.data();
    if (data == null) {
      throw EntityNotFoundException(latestRatesDocId, name: 'Exchange rates');
    }

    return ExchangeRates.fromFirestore(data);
  }
}
