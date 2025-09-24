// ignore_for_file: unnecessary_string_interpolations

import 'package:get/get.dart';
import 'package:tradez_it/data/models/dashboard_metric_model.dart';

import '../data/models/trade_data_model.dart';
import '../main_api_client.dart';

class DashBoardController extends GetxController {
  final MainApiClient mainApiClient;

  DashBoardController({required this.mainApiClient});

  var currentMonth = DateTime.now().obs;
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var trades = <String, TradeData>{}.obs;
  var dashBoardMetrics = <String, DashBoardMetricModel>{}.obs;
  var isLoading = false.obs;
  var isDashBoardDataLoading = false.obs;
  var overallMetrics = Rxn<Data>();

  @override
  void onInit() {
    print("=== CalendarController onInit ===");
    fetchMonthData();
    fetchDashBoardData();
    super.onInit();
  }

  void previousMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month - 1,
    );
    startDate.value = null;
    endDate.value = null;
    fetchMonthData();
    fetchDashBoardData();
  }

  void nextMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
    );
    startDate.value = null;
    endDate.value = null;
    fetchMonthData();
    fetchDashBoardData();
  }

  void updateDateRange(DateTime start, DateTime end) {
    print("=== updateDateRange called ===");
    print("Start date: $start");
    print("End date: $end");
    
    startDate.value = start;
    endDate.value = end;

    print("startDate.value after setting: ${startDate.value}");
    print("endDate.value after setting: ${endDate.value}");

    fetchDashBoardData();
    fetchMonthData();
  }

  // Helper method to convert DateTime to ISO string date format
  String _dateToString(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }

  Future<void> fetchMonthData() async {
    print("=== fetchMonthData called ===");
    isLoading.value = true;
    
    final firstDay = startDate.value ?? 
        DateTime(currentMonth.value.year, currentMonth.value.month, 1);
    final lastDay = endDate.value ?? 
        DateTime(currentMonth.value.year, currentMonth.value.month + 1, 0);
    
    print("fetchMonthData - firstDay: $firstDay");
    print("fetchMonthData - lastDay: $lastDay");
    print("fetchMonthData - startDate string: ${_dateToString(firstDay)}");
    print("fetchMonthData - endDate string: ${_dateToString(lastDay)}");
    
    try {
      final data = await mainApiClient.calendarApiClient.fetchCalendarData(
        accountId: mainApiClient.accountId,
        startDate: _dateToString(firstDay),
        endDate: _dateToString(lastDay),
      );
      
      print("fetchMonthData - Received data count: ${data.length}");
      
      trades.clear();
      for (final item in data) {
        final tradeData = TradeData.fromJson(item);
        trades[tradeData.tradeDate] = tradeData;
        print("fetchMonthData - Added trade for date: ${tradeData.tradeDate}");
      }
    } catch (e) {
      print("fetchMonthData - Error: $e");
      trades.clear();
      Get.snackbar(
        'Error',
        'Failed to load calendar data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDashBoardData() async {
    print("=== fetchDashBoardData called ===");
    isDashBoardDataLoading.value = true;
    
    final firstDay = startDate.value ?? 
        DateTime(currentMonth.value.year, currentMonth.value.month, 1);
    final lastDay = endDate.value ?? 
        DateTime(currentMonth.value.year, currentMonth.value.month + 1, 0);
    
    print("fetchDashBoardData - firstDay: $firstDay");
    print("fetchDashBoardData - lastDay: $lastDay");
    print("fetchDashBoardData - startDate string: ${_dateToString(firstDay)}");
    print("fetchDashBoardData - endDate string: ${_dateToString(lastDay)}");
    print("fetchDashBoardData - accountId: ${mainApiClient.accountId}");
    
    try {
      final metricData = await mainApiClient.calendarApiClient
          .fetchDashBoardMetrics(
        accountId: mainApiClient.accountId,
        startDate: _dateToString(firstDay),
        endDate: _dateToString(lastDay),
      );

      print("=== API Response Debug ===");
      print("Status: ${metricData.status}");
      print("Message: ${metricData.message}");
      print("Data is null: ${metricData.data == null}");
      
      if (metricData.data != null) {
        print("Net P&L: ${metricData.data!.netPnl}");
        print("Profit Factor: ${metricData.data!.profitFactor}");
        print("Daily P&L list is null: ${metricData.data!.dailyPnl == null}");
        print("Daily P&L count: ${metricData.data!.dailyPnl?.length ?? 0}");
        
        if (metricData.data!.dailyPnl != null && metricData.data!.dailyPnl!.isNotEmpty) {
          print("First few daily P&L entries:");
          for (int i = 0; i < (metricData.data!.dailyPnl!.length > 5 ? 5 : metricData.data!.dailyPnl!.length); i++) {
            final entry = metricData.data!.dailyPnl![i];
            print("  Date: ${entry.date}, P&L: ${entry.pnl}, Trades: ${entry.trades}");
          }
        } else {
          print("Daily P&L list is empty or null");
        }
      }

      // Store the overall metrics
      overallMetrics.value = metricData.data;
      print("overallMetrics.value set, is null: ${overallMetrics.value == null}");

      // Process daily_pnl list
      dashBoardMetrics.clear();
      if (metricData.data != null && metricData.data!.dailyPnl != null) {
        print("Processing ${metricData.data!.dailyPnl!.length} daily P&L entries");
        for (final dailyPnl in metricData.data!.dailyPnl!) {
          if (dailyPnl.date != null) {
            final dateKey = _dateToString(dailyPnl.date!);
            dashBoardMetrics[dateKey] = DashBoardMetricModel(
              status: 'success',
              data: Data(dailyPnl: [dailyPnl]),
            );
            print("Added dashboard metric for date: $dateKey, P&L: ${dailyPnl.pnl}");
          }
        }
        print("Total dashboard metrics added: ${dashBoardMetrics.length}");
      } else {
        print("No daily P&L data to process");
      }
      
    } catch (e) {
      print("fetchDashBoardData - Error: $e");
      print("Error type: ${e.runtimeType}");
      dashBoardMetrics.clear();
      overallMetrics.value = null;
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          'Failed to load dashboard data: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
    } finally {
      isDashBoardDataLoading.value = false;
      print("fetchDashBoardData completed. isDashBoardDataLoading: false");
    }
  }
}