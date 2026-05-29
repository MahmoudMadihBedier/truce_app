abstract class MarketRemoteDataSource {
  /// Returns a snapshot of current rates from the Truce backend.
  Future<TruceRatesSnapshot> getRates();
}

class TruceRatesSnapshot {
  final double usdToEgp;
  final double goldPerGramEgp;
  final double goldPerOzEgp;
  final DateTime lastUpdatedUtc;

  const TruceRatesSnapshot({
    required this.usdToEgp,
    required this.goldPerGramEgp,
    required this.goldPerOzEgp,
    required this.lastUpdatedUtc,
  });
}
