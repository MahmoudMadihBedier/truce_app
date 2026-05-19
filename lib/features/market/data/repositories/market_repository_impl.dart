import 'dart:math';
import '../../../../core/error/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/market_rate.dart';
import '../../domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  @override
  Future<Result<List<MarketRate>>> getMarketRates() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final random = Random();

      final goldBase = 3400.0 + random.nextDouble() * 200;
      final goldChange = (random.nextDouble() * 2) - 0.5;

      final usdBase = 48.0 + random.nextDouble() * 1.5;
      final usdChange = (random.nextDouble() * 0.6) - 0.3;

      return Result.success([
        MarketRate(
          label: 'Gold 24K',
          price: goldBase,
          changePercentage: double.parse(goldChange.toStringAsFixed(2)),
          isUp: goldChange >= 0
        ),
        MarketRate(
          label: 'USD Rate',
          price: double.parse(usdBase.toStringAsFixed(2)),
          changePercentage: double.parse(usdChange.abs().toStringAsFixed(2)),
          isUp: usdChange >= 0
        ),
      ]);
    } catch (e) {
      return Result.error(const ServerFailure('Failed to fetch market rates'));
    }
  }
}
