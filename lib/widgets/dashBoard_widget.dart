import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;


import '../controllers/dashboard_controller.dart';
import '../main_api_client.dart';

class DashboardWidget extends StatelessWidget {
  final DashBoardController controller = Get.find<DashBoardController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      color: Color.fromARGB(255, 17, 7, 62),
      child: Obx(() {
        final metricData = controller.overallMetrics.value;

        
     

        final netPnl = metricData?.netPnl ?? 0.0;
        final profitFactor = metricData?.profitFactor ?? 0.0;
        final tradeWinPct = metricData?.tradeWinPercentage ?? 0.0;
        final dayWinPct = metricData?.dayWinPercentage ?? 0.0;
        final winningTrades = metricData?.winningTrades ?? 0;
        final losingTrades = metricData?.losingTrades ?? 0;
        final winningDays = metricData?.winningDays ?? 0;
        final losingDays = metricData?.losingDays ?? 0;
        final avgWin = metricData?.avgWinPerTrade ?? 0.0;
        final avgLoss = metricData?.avgLossPerTrade ?? 0.0;

        final double absAvgLoss = avgLoss.abs();
        final double wlDenominator = avgWin + absAvgLoss;
        final double wlRecoveryPct = wlDenominator > 0
            ? (avgWin / wlDenominator)
            : 0.0;
        final double wlTrade = absAvgLoss != 0 ? (avgWin / absAvgLoss) : 0.0;

        Widget fullCircleGauge(double value, {double maxValue = 20.0}) {
          final double percent = (value / maxValue).clamp(0.0, 1.0);
          return SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: percent,
              backgroundColor: Colors.red.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 5,
            ),
          );
        }

        Widget semicircleGauge(double percentage, int positive, int negative) {
          return Container(
            width: 60,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 10,
                  child: CustomPaint(
                    size: Size(50, 30),
                    painter: SemicirclePainter(
                      percentage: percentage / 100.0,
                      strokeWidth: 5,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 5,
                  right: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$positive",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "$negative",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      title: "Net P&L",
                      value: "Rs. ${netPnl.toStringAsFixed(2)}",
                      color: netPnl >= 0 ? Colors.green : Colors.red,
                      infoIcon: true,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _infoCard(
                      title: "Profit Factor",
                      value: profitFactor.toStringAsFixed(2),
                      color: profitFactor >= 1.0 ? Colors.green : Colors.red,
                      infoIcon: true,
                      additional: fullCircleGauge(profitFactor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      title: "Trade Win %",
                      value: "${tradeWinPct.toStringAsFixed(2)}%",
                      color: Colors.white,
                      infoIcon: true,
                      additional: semicircleGauge(
                        tradeWinPct,
                        winningTrades,
                        losingTrades,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _infoCard(
                      title: "Day Win %",
                      value: "${dayWinPct.toStringAsFixed(2)}%",
                      color: Colors.white,
                      infoIcon: true,
                      additional: semicircleGauge(
                        dayWinPct,
                        winningDays,
                        losingDays,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Average W/L Trade",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.info_outline, color: Colors.white54, size: 16),
                      Spacer(),
                      Text(
                        "Recovery ${(wlRecoveryPct * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    wlTrade.isFinite && wlTrade >= 0
                        ? wlTrade.toStringAsFixed(2)
                        : "0.00",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: LinearProgressIndicator(
                      value: wlRecoveryPct.clamp(0.0, 1.0),
                      backgroundColor: Colors.red.withValues(),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs ${(absAvgLoss / 1000).toStringAsFixed(0)}K",
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                      Text(
                        "Rs ${(avgWin / 1000).toStringAsFixed(0)}K",
                        style: TextStyle(color: Colors.green, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showDateRangePicker(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                "Select Date Range",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required Color color,
    bool infoIcon = false,
    Widget? additional,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (infoIcon) ...[
                SizedBox(width: 6),
                Icon(Icons.info_outline, color: Colors.white54, size: 16),
              ],
              if (additional != null) ...[SizedBox(width: 8), additional],
            ],
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) {
    DateTime initialStartDate = controller.startDate.value ?? DateTime(2024, 2, 2);
    DateTime initialEndDate = controller.endDate.value ?? DateTime(2024, 6, 20);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color.fromARGB(255, 17, 7, 62),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Start Date",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    "End Date",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialStartDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                surface: Color.fromARGB(255, 17, 7, 62),
                                onSurface: Colors.white70,
                              ),
                              dialogBackgroundColor: Color.fromARGB(255, 17, 7, 62),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) initialStartDate = picked;
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${initialStartDate.day}/${initialStartDate.month}/${initialStartDate.year}",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialEndDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                surface: Color.fromARGB(255, 17, 7, 62),
                                onSurface: Colors.white70,
                              ),
                              dialogBackgroundColor: Color.fromARGB(255, 17, 7, 62),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) initialEndDate = picked;
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${initialEndDate.day}/${initialEndDate.month}/${initialEndDate.year}",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      controller.updateDateRange(initialStartDate, initialEndDate);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Submit", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SemicirclePainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;

  SemicirclePainter({
    required this.percentage,
    this.strokeWidth = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    final progressPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}