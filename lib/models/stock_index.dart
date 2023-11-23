class StockIndex {
  final DateTime date;
  final double close;
  final double open;
  final double high;
  final double low;
  final double volume;
  final double adjustedClose;

  StockIndex({
    required this.date,
    required this.close,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.adjustedClose,
  });
}
