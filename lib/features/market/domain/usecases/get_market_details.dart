import '../../../../core/error/result.dart';
import '../entities/market_details.dart';
import '../entities/market_instrument.dart';
import '../repositories/market_repository.dart';

class GetMarketDetails {
  final MarketRepository repository;

  GetMarketDetails(this.repository);

  Future<Result<MarketDetails>> call(MarketInstrument instrument) async {
    return repository.getMarketDetails(instrument);
  }
}

