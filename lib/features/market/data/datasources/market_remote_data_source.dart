abstract class MarketRemoteDataSource {
  /// Returns how many EGP for 1 USD.
  Future<double> getUsdToEgp();

  /// Returns gold 24K price per gram in EGP.
  Future<double> getGold24kEgpPerGram();

  Future<MarketLatestSnapshot> getLatest({required String base, required String currency});

  Future<MarketOhlcSnapshot> getOhlc({
    required String base,
    required String currency,
    required DateTime date,
  });

  Future<MarketChangeSnapshot> getChangeWeek({required String base, required String currency});
}

class MarketLatestSnapshot {
  final String base;
  final String currency;
  final double rate;
  final DateTime timestamp;

  const MarketLatestSnapshot({
    required this.base,
    required this.currency,
    required this.rate,
    required this.timestamp,
  });
}

class MarketOhlcSnapshot {
  final String base;
  final String currency;
  final double open;
  final double high;
  final double low;
  final double close;
  final DateTime timestamp;
  final DateTime date;

  const MarketOhlcSnapshot({
    required this.base,
    required this.currency,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.timestamp,
    required this.date,
  });
}

class MarketChangeSnapshot {
  final String base;
  final String currency;
  final double startRate;
  final double endRate;
  final double change;
  final double changePct;
  final DateTime startDate;
  final DateTime endDate;

  const MarketChangeSnapshot({
    required this.base,
    required this.currency,
    required this.startRate,
    required this.endRate,
    required this.change,
    required this.changePct,
    required this.startDate,
    required this.endDate,
  });
}

