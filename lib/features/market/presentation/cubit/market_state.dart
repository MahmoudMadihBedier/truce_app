import 'package:equatable/equatable.dart';
import '../../domain/entities/market_rate.dart';

class MarketState extends Equatable {
  final List<MarketRate> rates;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const MarketState({
    required this.rates,
    required this.isLoading,
    this.errorMessage,
    this.lastUpdated,
  });

  factory MarketState.initial() => const MarketState(rates: [], isLoading: false);

  MarketState copyWith({
    List<MarketRate>? rates,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return MarketState(
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [rates, isLoading, errorMessage, lastUpdated];
}

