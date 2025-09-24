import 'package:get/get.dart';
import 'package:tradez_it/data/models/dashboard_metric_model.dart';

import '../data/models/trade_data_model.dart';
import '../main_api_client.dart';

class CalendarController extends GetxController {
 final MainApiClient mainApiClient;

  CalendarController({required this.mainApiClient});

  var currentMonth = DateTime.now().obs;
  var trades = <String, TradeData>{}.obs;
  var dashBoardMetrics = <String, DashBoardMetricModel>{}.obs;

  var isLoading = false.obs;
  var isDashBoardDataLoading = false.obs;
  var overallMetrics = Rxn<Data>();
  @override
  void onInit() {
    fetchMonthData();
    fetchDashBoarddata();
    super.onInit();
  }

  void previousMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month - 1,
    );
    fetchMonthData();
  }

  void nextMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
    );
    fetchMonthData();
  }

  Future<void> fetchMonthData() async {
    isLoading.value = true;
    final firstDay = DateTime(
      currentMonth.value.year,
      currentMonth.value.month,
      1,
    );
    final lastDay = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
      0,
    );
    try {
      final data = await mainApiClient.calendarApiClient.fetchCalendarData(
        accountId: mainApiClient.accountId,
        startDate: "${firstDay.toIso8601String().substring(0, 10)}",
        endDate: "${lastDay.toIso8601String().substring(0, 10)}",
      );
      trades.clear();
      for (final item in data) {
        final tradeData = TradeData.fromJson(item);
        trades[tradeData.tradeDate] = tradeData;
      }
    } catch (e) {
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

  Future<void> fetchDashBoarddata() async {
    isDashBoardDataLoading.value = true;
    final firstDay = DateTime(
      currentMonth.value.year,
      currentMonth.value.month,
      1,
    );
    final lastDay = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
      0,
    );
    try {
      final metricData = await mainApiClient.calendarApiClient
          .fetchDashBoardMetrics(
            accountId: mainApiClient.accountId,
            startDate: "2021-02-01",
            endDate: "2024-12-31",
          );
      //      startDate: "${firstDay.toIso8601String().substring(0, 10)}",
      // endDate: "${lastDay.toIso8601String().substring(0, 10)}",

      // Print net_pnl and other fields to verify data
      print('Net PNL: ${metricData.data?.netPnl ?? 'null'}');
      print('Profit Factor: ${metricData.data?.profitFactor ?? 'null'}');
      print('Winning Trades: ${metricData.data?.winningTrades ?? 'null'}');
      print('Daily PNL Count: ${metricData.data?.dailyPnl?.length ?? 0}');

      // Store the overall metrics
      overallMetrics.value = metricData.data;

      // Process daily_pnl list
      dashBoardMetrics.clear();
      if (metricData.data != null && metricData.data!.dailyPnl != null) {
        for (final dailyPnl in metricData.data!.dailyPnl!) {
          if (dailyPnl.date != null) {
            dashBoardMetrics[dailyPnl.date!.toIso8601String().substring(
              0,
              10,
            )] = DashBoardMetricModel(
              status: 'success',
              data: Data(dailyPnl: [dailyPnl]),
            );
          }
        }
      }
    } catch (e) {
      dashBoardMetrics.clear();
      overallMetrics.value = null;
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          'Failed to load dashboard data: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      } else {
        print('Error: Failed to load dashboard data: $e');
      }
    } finally {
      isDashBoardDataLoading.value = false;
    }
  }
}
