import '../../../../core/error/result.dart';
import '../../../../core/error/failures.dart';
import '../datasources/market_remote_data_source.dart';
import '../../domain/entities/market_details.dart';
import '../../domain/entities/market_instrument.dart';
import '../../domain/entities/market_rate.dart';
import '../../domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource _remote;

  MarketRepositoryImpl(this._remote);

  static const _gold21kRatio = 21.0 / 24.0;
  static const _gold18kRatio = 18.0 / 24.0;

  @override
  Future<Result<List<MarketRate>>> getMarketRates() async {
    try {
      final snapshot = await _remote.getRates();

      final gold24k = snapshot.goldPerGramEgp;
      final gold21k = gold24k * _gold21kRatio;
      final gold18k = gold24k * _gold18kRatio;

      return Result.success([
        MarketRate(label: 'Gold 24K', price: gold24k, changePercentage: 0, isUp: true),
        MarketRate(label: 'Gold 21K', price: gold21k, changePercentage: 0, isUp: true),
        MarketRate(label: 'Gold 18K', price: gold18k, changePercentage: 0, isUp: true),
        MarketRate(label: 'USD Rate', price: snapshot.usdToEgp, changePercentage: 0, isUp: true),
      ]);
    } on Failure catch (f) {
      return Result.error(f);
    } catch (e) {
      return Result.error(ServerFailure('Failed to fetch market rates: $e'));
    }
  }

  @override
  Future<Result<MarketDetails>> getMarketDetails(MarketInstrument instrument) async {
    try {
      final snapshot = await _remote.getRates();

      // For gold: pass per-oz rate so the dialog can show all gram denominations.
      // For USD: pass the direct exchange rate.
      final double latestRate;
      switch (instrument) {
        case MarketInstrument.gold24k:
          latestRate = snapshot.goldPerOzEgp;
          break;
        case MarketInstrument.gold21k:
          latestRate = snapshot.goldPerOzEgp * _gold21kRatio;
          break;
        case MarketInstrument.gold18k:
          latestRate = snapshot.goldPerOzEgp * _gold18kRatio;
          break;
        case MarketInstrument.usd:
          latestRate = snapshot.usdToEgp;
          break;
      }

      return Result.success(MarketDetails(
        instrument: instrument,
        latestRate: latestRate,
        latestTimestamp: snapshot.lastUpdatedUtc,
        ohlc: null,
        changeWeek: null,
      ));
    } on Failure catch (f) {
      return Result.error(f);
    } catch (e) {
      return Result.error(ServerFailure('Failed to fetch market details: $e'));
    }
  }
}
