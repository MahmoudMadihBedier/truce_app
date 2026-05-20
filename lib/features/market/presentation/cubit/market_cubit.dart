import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_market_rates.dart';
import '../../domain/entities/market_rate.dart';

class MarketCubit extends Cubit<List<MarketRate>> {
  final GetMarketRates getMarketRates;

  DateTime? _lastFetched;
  static const _cacheDuration = Duration(minutes: 5);

  MarketCubit({required this.getMarketRates}) : super([]);

  Future<void> fetchRates({bool forceRefresh = false}) async {
    // Return cached data if within cache window
    if (!forceRefresh && _lastFetched != null && state.isNotEmpty) {
      final elapsed = DateTime.now().difference(_lastFetched!);
      if (elapsed < _cacheDuration) {
        return;
      }
    }

    final result = await getMarketRates();
    if (result.isSuccess) {
      _lastFetched = DateTime.now();
      emit(result.data!);
    }
  }
}
