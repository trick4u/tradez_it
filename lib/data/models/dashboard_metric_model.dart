import 'package:intl/intl.dart';

class DashBoardMetricModel {
  String? status;
  String? message;
  Data? data;

  DashBoardMetricModel({this.status, this.message, this.data});

  factory DashBoardMetricModel.fromJson(Map<String, dynamic> json) {
    return DashBoardMetricModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? Data.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Data {
  double? netPnl;
  double? profitFactor;
  double? tradeWinPercentage;
  double? dayWinPercentage;
  int? winningTrades;
  int? losingTrades;
  int? winningDays;
  int? losingDays;
  double? grossProfit;
  double? grossLoss;
  double? avgWinPerTrade;
  double? avgLossPerTrade;
  List<DailyPnl>? dailyPnl;

  Data({
    this.netPnl,
    this.profitFactor,
    this.tradeWinPercentage,
    this.dayWinPercentage,
    this.winningTrades,
    this.losingTrades,
    this.winningDays,
    this.losingDays,
    this.grossProfit,
    this.grossLoss,
    this.avgWinPerTrade,
    this.avgLossPerTrade,
    this.dailyPnl,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      netPnl: (json['net_pnl'] as num?)?.toDouble(),
      profitFactor: (json['profit_factor'] as num?)?.toDouble(),
      tradeWinPercentage: (json['trade_win_percentage'] as num?)?.toDouble(),
      dayWinPercentage: (json['day_win_percentage'] as num?)?.toDouble(),
      winningTrades: json['winning_trades'] as int?,
      losingTrades: json['losing_trades'] as int?,
      winningDays: json['winning_days'] as int?,
      losingDays: json['losing_days'] as int?,
      grossProfit: (json['gross_profit'] as num?)?.toDouble(),
      grossLoss: (json['gross_loss'] as num?)?.toDouble(),
      avgWinPerTrade: (json['avg_win_per_trade'] as num?)?.toDouble(),
      avgLossPerTrade: (json['avg_loss_per_trade'] as num?)?.toDouble(),
     dailyPnl: (json['daily_pnl'] is List)
    ? (json['daily_pnl'] as List).map((item) => DailyPnl.fromJson(item)).toList()
    : [],
    );
  }
}

class DailyPnl {
  DateTime? date;
  double? pnl;
  int? trades;

  DailyPnl({this.date, this.pnl, this.trades});

  factory DailyPnl.fromJson(Map<String, dynamic> json) {
    return DailyPnl(
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
      pnl: (json['pnl'] as num?)?.toDouble(),
      trades: json['trades'] as int?,
    );
  }
}
