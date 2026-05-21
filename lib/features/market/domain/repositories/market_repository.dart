import '../../../../core/error/result.dart';
import '../entities/market_details.dart';
import '../entities/market_instrument.dart';
import '../entities/market_rate.dart';

abstract class MarketRepository {
  Future<Result<List<MarketRate>>> getMarketRates();
  Future<Result<MarketDetails>> getMarketDetails(MarketInstrument instrument);
}
