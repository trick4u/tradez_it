import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tradez_it/presentation/main_screen.dart';
import 'package:tradez_it/widgets/trading_calendar_widget.dart';

import 'main_api_client.dart';
import 'widgets/dashboard_widget.dart';

class DailyPnLChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailyPnL;

  DailyPnLChart({required this.dailyPnL});

  @override
  Widget build(BuildContext context) {
    // Calculate cumulative P&L
    List<Map<String, dynamic>> cumulativeData = [];
    double cumulativePnL = 0;
    for (var data in dailyPnL) {
      cumulativePnL += data['pnl'];
      cumulativeData.add({
        'date': data['date'],
        'cumulativePnL': cumulativePnL,
        'positiveValue': cumulativePnL >= 0 ? cumulativePnL : 0,
        'negativeValue': cumulativePnL < 0 ? cumulativePnL : 0,
      });
    }

    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // First Chart - Cumulative P&L (Area Chart)
            Container(
              height: 400,
              color: Color(0xFF1A1A2E),
              padding: EdgeInsets.all(10),
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                backgroundColor: Color(0xFF1A1A2E),
                primaryXAxis: DateTimeAxis(
                  labelStyle: TextStyle(color: Colors.white),
                  majorGridLines: MajorGridLines(width: 0),
                  dateFormat: DateFormat('dd/MM'),
                  intervalType: DateTimeIntervalType.days,
                  interval: 1,
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: TextStyle(color: Colors.white),
                  majorGridLines: MajorGridLines(
                    width: 0.5,
                    color: Colors.grey[700],
                  ),
                  minimum: -2000,
                  maximum: 7000,
                  interval: 1000,
                  numberFormat: NumberFormat.currency(symbol: '₹'),
                ),
                title: ChartTitle(
                  text: 'Daily Net Cumulative P&L',
                  textStyle: TextStyle(color: Colors.white, fontSize: 16),
                ),
                crosshairBehavior: CrosshairBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  lineType: CrosshairLineType.both,
                  lineColor: Colors.white.withOpacity(0.7),
                  lineWidth: 1,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x : point.y₹',
                ),
                series: <CartesianSeries>[
                  // Green area series for positive cumulative P&L
                  AreaSeries<Map<String, dynamic>, DateTime>(
                    dataSource: cumulativeData,
                    xValueMapper: (data, _) => DateTime.parse(data['date']),
                    yValueMapper: (data, _) => data['positiveValue'],
                    color: Color(0xFF2ECC71).withOpacity(0.6),
                    borderColor: Colors.transparent,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                  ),
                  // Red area series for negative cumulative P&L
                  AreaSeries<Map<String, dynamic>, DateTime>(
                    dataSource: cumulativeData,
                    xValueMapper: (data, _) => DateTime.parse(data['date']),
                    yValueMapper: (data, _) => data['negativeValue'],
                    color: Color(0xFFE74C3C).withOpacity(0.6),
                    borderColor: Colors.transparent,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                  ),
                  // Line series for cumulative P&L outline
                  LineSeries<Map<String, dynamic>, DateTime>(
                    dataSource: cumulativeData,
                    xValueMapper: (data, _) => DateTime.parse(data['date']),
                    yValueMapper: (data, _) => data['cumulativePnL'],
                    color: Colors.white,
                    width: 2,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Second Chart - Daily P&L Bar Chart (Like the screenshot)
            Container(
              height: 400,
              color: Color(0xFF2C3E50),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Net Daily P&L',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.white, size: 20),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      backgroundColor: Color(0xFF2C3E50),
                      primaryXAxis: DateTimeAxis(
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        majorGridLines: MajorGridLines(width: 0),
                        axisLine: AxisLine(width: 0),
                        dateFormat: DateFormat('dd/MM'),
                        intervalType: DateTimeIntervalType.days,
                        interval: 1,
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        majorGridLines: MajorGridLines(width: 0),
                        axisLine: AxisLine(width: 0),
                        numberFormat: NumberFormat.currency(symbol: '₹'),
                        minimum: -3000,
                        maximum: 7000,
                        interval: 2000,
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        format: 'point.x : ₹point.y',
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<Map<String, dynamic>, DateTime>(
                          dataSource: dailyPnL,
                          xValueMapper: (data, _) =>
                              DateTime.parse(data['date']),
                          yValueMapper: (data, _) => data['pnl'],
                          pointColorMapper: (data, _) => data['pnl'] >= 0
                              ? Color(0xFF2ECC71)
                              : Color(0xFFE74C3C),
                          width: 0.6,
                          spacing: 0.1,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: false,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  final mainApiClient = MainApiClient(
    baseUrl: "https://dev.tradezeit.cirqllabs.com",
    bearerToken:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU5MTI0MTYxLCJpYXQiOjE3NTg1MTkzNjEsImp0aSI6ImFkZTBiYTA3YWZhMjQ4YTc4YWM0OGFkYjM3ODVhNTc5IiwidXNlcl9pZCI6IjQ4ODgwMDIzLWZlMWYtNGEyNS05MmM4LTQzNTE4YWQxMDgxMSJ9.VDiLsbrNSfsgpDqValZMGSGhn59F2gfW3gMdC1qU8uk",
    accountId: "c64deeec-d85d-4a02-88d3-1530956fccaf",
  );

  // Register MainApiClient with GetX for dependency injection
  Get.put(mainApiClient);
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
      // home: DailyPnLChart(
      //   dailyPnL: [
      //     {"date": "2024-09-02", "pnl": 1200.0, "trades": 2},
      //     {"date": "2024-09-03", "pnl": 800.0, "trades": 1},
      //     {"date": "2024-09-04", "pnl": -450.0, "trades": 3},
      //     {"date": "2024-09-05", "pnl": 600.0, "trades": 2},
      //     {"date": "2024-09-06", "pnl": -1800.0, "trades": 4},
      //     {"date": "2024-09-09", "pnl": -900.0, "trades": 2},
      //     {"date": "2024-09-10", "pnl": 1500.0, "trades": 3},
      //     {"date": "2024-09-11", "pnl": -300.0, "trades": 1},
      //     {"date": "2024-09-12", "pnl": 750.0, "trades": 2},
      //     {"date": "2024-09-13", "pnl": -2200.0, "trades": 5},
      //     {"date": "2024-09-16", "pnl": 400.0, "trades": 1},
      //     {"date": "2024-09-17", "pnl": -650.0, "trades": 2},
      //     {"date": "2024-09-18", "pnl": 950.0, "trades": 3},
      //     {"date": "2024-09-19", "pnl": -1100.0, "trades": 3},
      //     {"date": "2024-09-20", "pnl": 1800.0, "trades": 4},
      //     {"date": "2024-09-23", "pnl": -500.0, "trades": 2},
      //     {"date": "2024-09-24", "pnl": 1200.0, "trades": 3},
      //     {"date": "2024-09-25", "pnl": -800.0, "trades": 2},
      //     {"date": "2024-09-26", "pnl": 350.0, "trades": 1},
      //     {"date": "2024-09-27", "pnl": -400.0, "trades": 2},
      //     {"date": "2024-09-30", "pnl": 2200.0, "trades": 5},
      //   ],
      // ),
    ),
  );
}
