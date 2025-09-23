class TradeData {
  final String tradeDate;
  final double dailyPnl;
  final int tradesPerDay;
  final bool hasDailyNote;

  TradeData({
    required this.tradeDate,
    required this.dailyPnl,
    required this.tradesPerDay,
    required this.hasDailyNote,
  });

  factory TradeData.fromJson(Map<String, dynamic> json) {
    return TradeData(
      tradeDate: json['trade_date'] as String,
      dailyPnl: (json['daily_pnl'] as num).toDouble(),
      tradesPerDay: json['trades_per_day'] as int,
      hasDailyNote: json['has_daily_note'] as bool,
    );
  }
}