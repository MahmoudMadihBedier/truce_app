import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import 'market_remote_data_source.dart';

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final ApiClient _apiClient;

  MarketRemoteDataSourceImpl(this._apiClient);

  @override
  Future<TruceRatesSnapshot> getRates() async {
    final response = await _apiClient.get('/api/rates');

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ServerFailure('Invalid rates response from server');
    }

    double parseNum(String key) {
      final v = data[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.parse(v);
      throw ServerFailure('Missing or invalid field "$key" in rates response');
    }

    final lastUpdatedRaw = data['last_updated_utc'];
    final DateTime lastUpdated = lastUpdatedRaw is String
        ? DateTime.parse(lastUpdatedRaw)
        : DateTime.now().toUtc();

    return TruceRatesSnapshot(
      usdToEgp: parseNum('usd_to_egp'),
      goldPerGramEgp: parseNum('gold_per_gram_egp'),
      goldPerOzEgp: parseNum('gold_per_oz_egp'),
      lastUpdatedUtc: lastUpdated,
    );
  }
}
