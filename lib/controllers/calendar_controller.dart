

import 'package:get/get.dart';

import '../data/models/trade_data_model.dart';
import '../main_api_client.dart';

class CalendarController extends GetxController {
  final MainApiClient mainApiClient;

  CalendarController({required this.mainApiClient});

  var currentMonth = DateTime.now().obs;
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var trades = <String, TradeData>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    print("=== CalendarController onInit ===");
    fetchMonthData();
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
  }

  void nextMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
    );
    startDate.value = null;
    endDate.value = null;
    fetchMonthData();
  }

  void updateDateRange(DateTime start, DateTime end) {
    print("=== CalendarController updateDateRange called ===");
    print("Start date: $start");
    print("End date: $end");
    
    startDate.value = start;
    endDate.value = end;

    print("startDate.value after setting: ${startDate.value}");
    print("endDate.value after setting: ${endDate.value}");

    fetchMonthData();
  }

  String _dateToString(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }

  Future<void> fetchMonthData() async {
    print("=== CalendarController fetchMonthData called ===");
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
}