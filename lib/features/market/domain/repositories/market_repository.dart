import '../../../../core/error/result.dart';
import '../entities/market_rate.dart';

abstract class MarketRepository {
  Future<Result<List<MarketRate>>> getMarketRates();
}
