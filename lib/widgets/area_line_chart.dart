import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../controllers/calendar_controller.dart';
import '../main_api_client.dart';

class DailyPnLChart extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final CalendarController controller = Get.put(
      CalendarController(mainApiClient: Get.find()),
    );

    return Obx(() {
      List<Map<String, dynamic>> dailyPnL = [];
      if (controller.overallMetrics.value != null &&
          controller.overallMetrics.value!.dailyPnl != null) {
        dailyPnL = controller.overallMetrics.value!.dailyPnl!
            .where((item) => item.date != null && item.pnl != null)
            .map((item) => {
                  'date': item.date!.toIso8601String().substring(0, 10),
                  'pnl': item.pnl!,
                })
            .toList();

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
          body: controller.isDashBoardDataLoading.value
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: PageView(
                    children: [
                      // First Page: Area chart with date picker button
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: () async {
                                final DateTimeRange? picked =
                                    await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                  initialDateRange: DateTimeRange(
                                    start: controller.startDate.value ??
                                        DateTime.now()
                                            .subtract(Duration(days: 30)),
                                    end:
                                        controller.endDate.value ?? DateTime.now(),
                                  ),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.dark().copyWith(
                                        colorScheme: ColorScheme.dark(
                                          primary: Color(0xFF2ECC71),
                                          onPrimary: Colors.white,
                                          surface: Color(0xFF1A1A2E),
                                          onSurface: Colors.white,
                                        ),
                                        dialogBackgroundColor:
                                            Color(0xFF1A1A2E),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  controller
                                      .updateDateRange(picked.start, picked.end);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2ECC71),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: Text(
                                'Select Date Range',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
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
                                interval: 10,
                              ),
                              primaryYAxis: NumericAxis(
                                labelStyle: TextStyle(color: Colors.white),
                                majorGridLines: MajorGridLines(
                                  width: 0.5,
                                  color: Colors.grey[700],
                                ),
                                minimum: -2000,
                                maximum: 5000,
                                interval: 1000,
                                numberFormat: NumberFormat.currency(symbol: '₹'),
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
                                format: 'point.x : point.y₹',
                              ),
                              series: [
                                // Green area series for positive cumulative P&L
                                AreaSeries<Map<String, dynamic>, DateTime>(
                                  dataSource: cumulativeData,
                                  xValueMapper: (data, _) =>
                                      DateTime.parse(data['date']),
                                  yValueMapper: (data, _) => data['positiveValue'],
                                  color: Color(0xFF2ECC71).withOpacity(0.6),
                                  borderColor: Colors.transparent,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: false,
                                  ),
                                ),
                                // Red area series for negative cumulative P&L
                                AreaSeries<Map<String, dynamic>, DateTime>(
                                  dataSource: cumulativeData,
                                  xValueMapper: (data, _) =>
                                      DateTime.parse(data['date']),
                                  yValueMapper: (data, _) => data['negativeValue'],
                                  color: Color(0xFFE74C3C).withOpacity(0.6),
                                  borderColor: Colors.transparent,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: false,
                                  ),
                                ),
                                // Line series for cumulative P&L outline
                                LineSeries<Map<String, dynamic>, DateTime>(
                                  dataSource: cumulativeData,
                                  xValueMapper: (data, _) =>
                                      DateTime.parse(data['date']),
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
                        ],
                      ),
                      // Second Page: Daily P&L Bar Chart
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
                                  interval: 10,
                                ),
                                primaryYAxis: NumericAxis(
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  majorGridLines: MajorGridLines(width: 0),
                                  axisLine: AxisLine(width: 0),
                                  numberFormat:
                                      NumberFormat.currency(symbol: '₹'),
                                  minimum: -3000,
                                  maximum: 5000,
                                  interval: 2000,
                                ),
                                tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  format: 'point.x : ₹point.y',
                                  textStyle: TextStyle(color: Colors.white),
                                ),
                                series: [
                                  ColumnSeries<Map<String, dynamic>, DateTime>(
                                    dataSource: dailyPnL,
                                    xValueMapper: (data, _) =>
                                        DateTime.parse(data['date']),
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
                ),
        );
      } else {
        return Scaffold(
          backgroundColor: Color(0xFF1A1A2E),
          body: Center(child: CircularProgressIndicator()),
        );
      }
    });
  }
}