import 'package:dio/dio.dart';
import '../../../../core/config/metalpriceapi_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import 'market_remote_data_source.dart';

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final ApiClient _apiClient;

  MarketRemoteDataSourceImpl(this._apiClient);

  @override
  Future<double> getUsdToEgp() async {
    final snapshot = await getLatest(base: 'USD', currency: 'EGP');
    return snapshot.rate;
  }

  @override
  Future<double> getGold24kEgpPerGram() async {
    // Use XAU (1 troy ounce of gold) as base, get its value in EGP.
    // Convert ounce -> gram to display a more familiar "Gold 24K" price.
    const gramsPerTroyOunce = 31.1034768;
    final snapshot = await getLatest(base: 'XAU', currency: 'EGP');
    return snapshot.rate / gramsPerTroyOunce;
  }

  @override
  Future<MarketLatestSnapshot> getLatest({required String base, required String currency}) async {
    if (MetalPriceApiConfig.apiKey.isEmpty) {
      throw const ValidationFailure('Missing METALPRICE_API_KEY');
    }

    final Response response = await _apiClient.get(
      '${MetalPriceApiConfig.baseUrl}/latest',
      queryParameters: {
        'api_key': MetalPriceApiConfig.apiKey,
        'base': base,
        'currencies': currency,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ServerFailure('Invalid response from metalpriceapi');
    }

    final rawTimestamp = data['timestamp'];
    if (rawTimestamp is! num) {
      throw const ServerFailure('Missing timestamp in metalpriceapi response');
    }

    final rates = data['rates'];
    if (rates is! Map) {
      throw const ServerFailure('Missing rates in metalpriceapi response');
    }

    final dynamic raw = rates[currency];
    final double parsedRate;
    if (raw is num) {
      parsedRate = raw.toDouble();
    } else if (raw is String) {
      parsedRate = double.parse(raw);
    } else {
      throw ServerFailure('Missing $currency rate in metalpriceapi response');
    }

    return MarketLatestSnapshot(
      base: base,
      currency: currency,
      rate: parsedRate,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (rawTimestamp.toDouble() * 1000).round(),
        isUtc: true,
      ),
    );
  }

  @override
  Future<MarketOhlcSnapshot> getOhlc({
    required String base,
    required String currency,
    required DateTime date,
  }) async {
    if (MetalPriceApiConfig.apiKey.isEmpty) {
      throw const ValidationFailure('Missing METALPRICE_API_KEY');
    }

    final yyyy = date.toUtc().year.toString().padLeft(4, '0');
    final mm = date.toUtc().month.toString().padLeft(2, '0');
    final dd = date.toUtc().day.toString().padLeft(2, '0');
    final formattedDate = '$yyyy-$mm-$dd';

    final Response response = await _apiClient.get(
      '${MetalPriceApiConfig.baseUrl}/ohlc',
      queryParameters: {
        'api_key': MetalPriceApiConfig.apiKey,
        'base': base,
        'currency': currency,
        'date': formattedDate,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ServerFailure('Invalid OHLC response from metalpriceapi');
    }

    final rawTimestamp = data['timestamp'];
    if (rawTimestamp is! num) {
      throw const ServerFailure('Missing timestamp in OHLC response');
    }

    final rate = data['rate'];
    if (rate is! Map) {
      throw const ServerFailure('Missing rate in OHLC response');
    }

    double readNum(String key) {
      final v = rate[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.parse(v);
      throw ServerFailure('Missing $key in OHLC response');
    }

    return MarketOhlcSnapshot(
      base: base,
      currency: currency,
      open: readNum('open'),
      high: readNum('high'),
      low: readNum('low'),
      close: readNum('close'),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (rawTimestamp.toDouble() * 1000).round(),
        isUtc: true,
      ),
      date: DateTime.parse(formattedDate),
    );
  }

  @override
  Future<MarketChangeSnapshot> getChangeWeek({required String base, required String currency}) async {
    if (MetalPriceApiConfig.apiKey.isEmpty) {
      throw const ValidationFailure('Missing METALPRICE_API_KEY');
    }

    final Response response = await _apiClient.get(
      '${MetalPriceApiConfig.baseUrl}/change',
      queryParameters: {
        'api_key': MetalPriceApiConfig.apiKey,
        'base': base,
        'currencies': currency,
        'date_type': 'week',
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ServerFailure('Invalid change response from metalpriceapi');
    }

    final startDateRaw = data['start_date'];
    final endDateRaw = data['end_date'];
    if (startDateRaw is! String || endDateRaw is! String) {
      throw const ServerFailure('Missing start/end date in change response');
    }

    final rates = data['rates'];
    if (rates is! Map) {
      throw const ServerFailure('Missing rates in change response');
    }

    final entry = rates[currency];
    if (entry is! Map) {
      throw ServerFailure('Missing $currency in change response');
    }

    double readNum(String key) {
      final v = entry[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.parse(v);
      throw ServerFailure('Missing $key in change response');
    }

    return MarketChangeSnapshot(
      base: base,
      currency: currency,
      startRate: readNum('start_rate'),
      endRate: readNum('end_rate'),
      change: readNum('change'),
      changePct: readNum('change_pct'),
      startDate: DateTime.parse(startDateRaw),
      endDate: DateTime.parse(endDateRaw),
    );
  }
}
