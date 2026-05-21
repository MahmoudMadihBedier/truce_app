import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/result.dart';
import '../../domain/usecases/get_market_rates.dart';
import '../../domain/usecases/get_market_details.dart';
import '../../domain/entities/market_details.dart';
import '../../domain/entities/market_rate.dart';
import '../../domain/entities/market_instrument.dart';

import 'market_state.dart';

class MarketCubit extends Cubit<MarketState> {
  final GetMarketRates getMarketRates;
  final GetMarketDetails getMarketDetails;

  DateTime? _lastFetched;
  static const _cacheDuration = Duration(minutes: 5);

  MarketCubit({
    required this.getMarketRates,
    required this.getMarketDetails,
  }) : super(MarketState.initial());

  Future<void> fetchRates({bool forceRefresh = false}) async {
    // Return cached data if within cache window
    if (!forceRefresh && _lastFetched != null && state.rates.isNotEmpty) {
      final elapsed = DateTime.now().difference(_lastFetched!);
      if (elapsed < _cacheDuration) {
        return;
      }
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await getMarketRates();
    if (result.isSuccess) {
      _lastFetched = DateTime.now();
      final updatedRates = _applyDelta(previous: state.rates, next: result.data!);
      emit(state.copyWith(
        rates: updatedRates,
        isLoading: false,
        errorMessage: null,
        lastUpdated: _lastFetched,
      ));
    } else {
      emit(state.copyWith(isLoading: false, errorMessage: result.failure!.message));
    }
  }

  List<MarketRate> _applyDelta({required List<MarketRate> previous, required List<MarketRate> next}) {
    if (previous.isEmpty) {
      return next
          .map((r) => MarketRate(label: r.label, price: r.price, changePercentage: 0, isUp: true))
          .toList(growable: false);
    }

    final prevByLabel = {for (final r in previous) r.label: r};
    return next.map((r) {
      final prev = prevByLabel[r.label];
      if (prev == null || prev.price == 0) {
        return MarketRate(label: r.label, price: r.price, changePercentage: 0, isUp: true);
      }
      final diff = r.price - prev.price;
      final pct = (diff / prev.price) * 100.0;
      return MarketRate(
        label: r.label,
        price: r.price,
        changePercentage: pct.abs(),
        isUp: diff >= 0,
      );
    }).toList(growable: false);
  }

  Future<Result<MarketDetails>> fetchDetails(MarketInstrument instrument) {
    return getMarketDetails(instrument);
  }
}
