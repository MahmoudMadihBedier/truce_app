import '../../../../core/error/result.dart';
import '../entities/market_rate.dart';
import '../repositories/market_repository.dart';

class GetMarketRates {
  final MarketRepository repository;

  GetMarketRates(this.repository);

  Future<Result<List<MarketRate>>> call() async {
    return await repository.getMarketRates();
  }
}
