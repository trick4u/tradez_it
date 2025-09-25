import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../controllers/dashboard_controller.dart';
import '../main_api_client.dart';

class DailyPnLChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DashBoardController controller = Get.find<DashBoardController>();

    return Obx(() {
      print("=== DailyPnLChart build ===");
      print("overallMetrics.value is null: ${controller.overallMetrics.value == null}");
      
      if (controller.overallMetrics.value != null) {
        print("dailyPnl is null: ${controller.overallMetrics.value!.dailyPnl == null}");
        if (controller.overallMetrics.value!.dailyPnl != null) {
          print("dailyPnl length: ${controller.overallMetrics.value!.dailyPnl!.length}");
        }
      }

      List<Map<String, dynamic>> dailyPnL = [];
      if (controller.overallMetrics.value != null &&
          controller.overallMetrics.value!.dailyPnl != null) {
        
        // Filter out null values and convert to the required format
        dailyPnL = controller.overallMetrics.value!.dailyPnl!
            .where((item) {
              bool hasValidData = item.date != null && item.pnl != null;
              if (!hasValidData) {
                print("Filtering out item with null date or pnl: date=${item.date}, pnl=${item.pnl}");
              }
              return hasValidData;
            })
            .map((item) {
              String dateStr = item.date!.toIso8601String().substring(0, 10);
              double pnlValue = item.pnl!.toDouble();
              print("Processing item: date=$dateStr, pnl=$pnlValue");
              return {
                'date': dateStr,
                'pnl': pnlValue,
              };
            })
            .toList();

        print("Processed dailyPnL length: ${dailyPnL.length}");

        if (dailyPnL.isEmpty) {
          return Container(
            height: 400,
            color: Color(0xFF1A1A2E),
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, color: Colors.white54, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No chart data available for the selected date range',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

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

        print("Cumulative data length: ${cumulativeData.length}");
        if (cumulativeData.isNotEmpty) {
          print("First cumulative entry: ${cumulativeData.first}");
          print("Last cumulative entry: ${cumulativeData.last}");
        }

        // Calculate dynamic Y-axis range for cumulative chart
        double minCumulativePnL = cumulativeData.map((e) => e['cumulativePnL'] as double).reduce((a, b) => a < b ? a : b);
        double maxCumulativePnL = cumulativeData.map((e) => e['cumulativePnL'] as double).reduce((a, b) => a > b ? a : b);
        
        // Add some padding to the range
        double cumulativeRange = maxCumulativePnL - minCumulativePnL;
        double cumulativePadding = cumulativeRange * 0.1; // 10% padding
        double cumulativeYMin = minCumulativePnL - cumulativePadding;
        double cumulativeYMax = maxCumulativePnL + cumulativePadding;
        
        // Ensure minimum range for cumulative chart
        if (cumulativeRange < 1000) {
          cumulativeYMin = minCumulativePnL - 500;
          cumulativeYMax = maxCumulativePnL + 500;
        }

        // Calculate dynamic Y-axis range for daily P&L bar chart
        double minDailyPnL = dailyPnL.map((e) => e['pnl'] as double).reduce((a, b) => a < b ? a : b);
        double maxDailyPnL = dailyPnL.map((e) => e['pnl'] as double).reduce((a, b) => a > b ? a : b);
        
        // Add padding for daily chart
        double dailyRange = maxDailyPnL - minDailyPnL;
        double dailyPadding = dailyRange * 0.1;
        double dailyYMin = minDailyPnL - dailyPadding;
        double dailyYMax = maxDailyPnL + dailyPadding;
        
        // Ensure minimum range for daily chart
        if (dailyRange < 1000) {
          dailyYMin = minDailyPnL - 500;
          dailyYMax = maxDailyPnL + 500;
        }

        return Container(
          height: 400,
          color: Color(0xFF1A1A2E),
          child: PageView(
            children: [
              // First Page: Cumulative Area Chart
              Container(
                padding: EdgeInsets.all(10),
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  backgroundColor: Color(0xFF1A1A2E),
                  primaryXAxis: DateTimeAxis(
                    labelStyle: TextStyle(color: Colors.white),
                    majorGridLines: MajorGridLines(width: 0),
                    dateFormat: DateFormat('dd/MM'),
                    intervalType: DateTimeIntervalType.days,
                    interval: dailyPnL.length > 30 ? (dailyPnL.length ~/ 10).toDouble() : 5,
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle: TextStyle(color: Colors.white),
                    majorGridLines: MajorGridLines(
                      width: 0.5,
                      color: Colors.grey[700],
                    ),
                    minimum: cumulativeYMin,
                    maximum: cumulativeYMax,
                    interval: (cumulativeYMax - cumulativeYMin) / 5,
                    numberFormat: NumberFormat.currency(symbol: '₹', decimalDigits: 0),
                  ),
                  title: ChartTitle(
                    text: 'Daily Net Cumulative P&L',
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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
                    format: 'point.x : ₹point.y',
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  series: [
                    // Positive area series
                    AreaSeries<Map<String, dynamic>, DateTime>(
                      dataSource: cumulativeData,
                      xValueMapper: (data, _) => DateTime.parse(data['date']),
                      yValueMapper: (data, _) => data['positiveValue'],
                      color: Color(0xFF2ECC71).withOpacity(0.6),
                      borderColor: Colors.transparent,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: false,
                      ),
                    ),
                    // Negative area series
                    AreaSeries<Map<String, dynamic>, DateTime>(
                      dataSource: cumulativeData,
                      xValueMapper: (data, _) => DateTime.parse(data['date']),
                      yValueMapper: (data, _) => data['negativeValue'],
                      color: Color(0xFFE74C3C).withOpacity(0.6),
                      borderColor: Colors.transparent,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: false,
                      ),
                    ),
                    // Main line series
                    LineSeries<Map<String, dynamic>, DateTime>(
                      dataSource: cumulativeData,
                      xValueMapper: (data, _) => DateTime.parse(data['date']),
                      yValueMapper: (data, _) => data['cumulativePnL'],
                      color: Colors.white,
                      width: 2,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: false,
                      ),
                    ),
                  ],
                ),
              ),

              // Second Page: Daily P&L Bar Chart
              Container(
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
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                        Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 20,
                        ),
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
                          interval: dailyPnL.length > 20 ? (dailyPnL.length ~/ 8).toDouble() : 5,
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          majorGridLines: MajorGridLines(width: 0),
                          axisLine: AxisLine(width: 0),
                          numberFormat: NumberFormat.currency(symbol: '₹', decimalDigits: 0),
                          minimum: dailyYMin,
                          maximum: dailyYMax,
                          interval: (dailyYMax - dailyYMin) / 4,
                        ),
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          format: 'point.x : ₹point.y',
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        series: [
                          ColumnSeries<Map<String, dynamic>, DateTime>(
                            dataSource: dailyPnL,
                            xValueMapper: (data, _) => DateTime.parse(data['date']),
                            yValueMapper: (data, _) => data['pnl'],
                            pointColorMapper: (data, _) =>
                                data['pnl'] >= 0
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
        );
      } else {
        return Container(
          height: 400,
          color: Color(0xFF1A1A2E),
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Loading chart data...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}