class MarketRate {
  final String label;
  final double price;
  final double changePercentage;
  final bool isUp;

  const MarketRate({
    required this.label,
    required this.price,
    required this.changePercentage,
    required this.isUp,
  });
}
