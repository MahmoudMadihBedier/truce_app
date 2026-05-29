import 'market_instrument.dart';

class MarketOhlc {
  final double open;
  final double high;
  final double low;
  final double close;
  final DateTime timestamp;
  final DateTime date;

  const MarketOhlc({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.timestamp,
    required this.date,
  });
}

class MarketChange {
  final double startRate;
  final double endRate;
  final double change;
  final double changePct;
  final DateTime startDate;
  final DateTime endDate;

  const MarketChange({
    required this.startRate,
    required this.endRate,
    required this.change,
    required this.changePct,
    required this.startDate,
    required this.endDate,
  });
}

class MarketDetails {
  final MarketInstrument instrument;

  // Rate returned by the API for the chosen base/currency pair (metals in troy ounce).
  final double latestRate;
  final DateTime latestTimestamp;

  final MarketOhlc? ohlc;
  final MarketChange? changeWeek;

  const MarketDetails({
    required this.instrument,
    required this.latestRate,
    required this.latestTimestamp,
    this.ohlc,
    this.changeWeek,
  });
}

