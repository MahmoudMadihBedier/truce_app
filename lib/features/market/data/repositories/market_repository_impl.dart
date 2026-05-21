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

  @override
  Future<Result<List<MarketRate>>> getMarketRates() async {
    try {
      final gold24kPerGramEgp = await _remote.getGold24kEgpPerGram();
      const gold21kRatio = 21.0 / 24.0;
      const gold18kRatio = 18.0 / 24.0;
      final gold21kPerGramEgp = gold24kPerGramEgp * gold21kRatio;
      final gold18kPerGramEgp = gold24kPerGramEgp * gold18kRatio;
      final usdToEgp = await _remote.getUsdToEgp();

      return Result.success([
        MarketRate(
          label: 'Gold 24K',
          price: gold24kPerGramEgp,
          changePercentage: 0,
          isUp: true,
        ),
        MarketRate(
          label: 'Gold 21K',
          price: gold21kPerGramEgp,
          changePercentage: 0,
          isUp: true,
        ),
        MarketRate(
          label: 'Gold 18K',
          price: gold18kPerGramEgp,
          changePercentage: 0,
          isUp: true,
        ),
        MarketRate(
          label: 'USD Rate',
          price: usdToEgp,
          changePercentage: 0,
          isUp: true,
        ),
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
      final nowUtc = DateTime.now().toUtc();
      final yesterdayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day).subtract(const Duration(days: 1));

      final String base;
      const currency = 'EGP';
      switch (instrument) {
        case MarketInstrument.gold24k:
        case MarketInstrument.gold21k:
        case MarketInstrument.gold18k:
          base = 'XAU';
          break;
        case MarketInstrument.usd:
          base = 'USD';
          break;
      }

      final latest = await _remote.getLatest(base: base, currency: currency);

      MarketOhlc? ohlc;
      try {
        final ohlcSnap = await _remote.getOhlc(base: base, currency: currency, date: yesterdayUtc);
        ohlc = MarketOhlc(
          open: ohlcSnap.open,
          high: ohlcSnap.high,
          low: ohlcSnap.low,
          close: ohlcSnap.close,
          timestamp: ohlcSnap.timestamp,
          date: ohlcSnap.date,
        );
      } catch (_) {
        ohlc = null;
      }

      MarketChange? changeWeek;
      try {
        final changeSnap = await _remote.getChangeWeek(base: base, currency: currency);
        changeWeek = MarketChange(
          startRate: changeSnap.startRate,
          endRate: changeSnap.endRate,
          change: changeSnap.change,
          changePct: changeSnap.changePct,
          startDate: changeSnap.startDate,
          endDate: changeSnap.endDate,
        );
      } catch (_) {
        changeWeek = null;
      }

      return Result.success(MarketDetails(
        instrument: instrument,
        latestRate: latest.rate,
        latestTimestamp: latest.timestamp,
        ohlc: ohlc,
        changeWeek: changeWeek,
      ));
    } on Failure catch (f) {
      return Result.error(f);
    } catch (e) {
      return Result.error(ServerFailure('Failed to fetch market details: $e'));
    }
  }
}
