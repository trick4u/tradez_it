import 'package:get/get.dart';
import 'package:tradez_it/data/models/dashboard_metric_model.dart';
import '../main_api_client.dart';

class DashBoardController extends GetxController {
  final MainApiClient mainApiClient;

  DashBoardController({required this.mainApiClient});

  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var dashBoardMetrics = <String, DashBoardMetricModel>{}.obs;
  var isDashBoardDataLoading = false.obs;
  var overallMetrics = Rxn<Data>();

  @override
  void onInit() {
    print("=== DashBoardController onInit ===");
    fetchDashBoardData();
    super.onInit();
  }

  void updateDateRange(DateTime start, DateTime end) {
    print("=== DashBoardController updateDateRange called ===");
    print("Start date: $start");
    print("End date: $end");
    
    startDate.value = start;
    endDate.value = end;

    print("startDate.value after setting: ${startDate.value}");
    print("endDate.value after setting: ${endDate.value}");

    fetchDashBoardData();
  }

  String _dateToString(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }

  Future<void> fetchDashBoardData() async {
    print("=== fetchDashBoardData called ===");
    isDashBoardDataLoading.value = true;
    
    final firstDay = startDate.value ?? DateTime.now();
    final lastDay = endDate.value ?? DateTime.now();
    
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

      overallMetrics.value = metricData.data;
      print("overallMetrics.value set, is null: ${overallMetrics.value == null}");

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