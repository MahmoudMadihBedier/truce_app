import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_market_rates.dart';
import '../../domain/entities/market_rate.dart';

class MarketCubit extends Cubit<List<MarketRate>> {
  final GetMarketRates getMarketRates;

  MarketCubit({required this.getMarketRates}) : super([]);

  Future<void> fetchRates() async {
    final result = await getMarketRates();
    if (result.isSuccess) {
      emit(result.data!);
    }
  }
}
