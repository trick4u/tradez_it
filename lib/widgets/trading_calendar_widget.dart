import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/dashboard_controller.dart';

import '../data/models/trade_data_model.dart';
import '../main_api_client.dart';

class TradingCalendarWidget extends StatelessWidget {
  const TradingCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController controller = Get.find<CalendarController>();
    return Container(
      padding: const EdgeInsets.all(16),
      color: Color.fromARGB(255, 17, 7, 62),
      child: Column(
        children: [
          Obx(() => buildHeader(controller)),
          buildWeekdayHeaders(),
          Obx(() {
            
           return buildCalendarGrid(controller);
          }),
        ],
      ),
    );
  }

  Widget buildHeader(CalendarController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: controller.previousMonth,
            icon: const Icon(Icons.chevron_left),
            color: Colors.white,
          ),
          Text(
            _getMonthYearString(controller.currentMonth.value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            onPressed: controller.nextMonth,
            icon: const Icon(Icons.chevron_right),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget buildWeekdayHeaders() {
    const weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekdays
            .map(
              (day) => Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF848E9C),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget buildCalendarGrid(CalendarController controller) {
    final currentMonth = controller.currentMonth.value;
    final trades = controller.trades;

    final daysInMonth = _getDaysInMonth(currentMonth);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: List.generate(42, (index) {
          final dayOffset = index - startingWeekday;
          if (dayOffset < 0 || dayOffset >= daysInMonth) {
            return SizedBox(
              width: (MediaQuery.of(Get.context!).size.width - 48) / 7 - 4,
              height: ((MediaQuery.of(Get.context!).size.width - 48) / 7 - 4) / 0.8,
            );
          }
          final day = dayOffset + 1;
          final dateKey = _formatDateKey(
            DateTime(currentMonth.year, currentMonth.month, day),
          );
          final TradeData? tradeData = controller.trades[dateKey];
          return SizedBox(
            width: (MediaQuery.of(Get.context!).size.width - 48) / 7 - 4,
            height: ((MediaQuery.of(Get.context!).size.width - 48) / 7 - 4) / 0.8,
            child: buildDayTile(day, tradeData),
          );
        }),
      ),
    );
  }

  Widget buildDayTile(int day, TradeData? tradeData) {
    Color backgroundColor = const Color(0xFF2B3139);
    Color textColor = Colors.white;

    if (tradeData != null) {
      backgroundColor = tradeData.dailyPnl >= 0
          ? const Color(0xFF0ECB81)
          : const Color(0xFFF6465D);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tradeData != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '₹${_formatPnl(tradeData.dailyPnl)}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '(${tradeData.tradesPerDay.toString().padLeft(2, '0')})',
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (tradeData?.hasDailyNote == true)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Icon(Icons.note, size: 12, color: textColor),
              ),
            ),
        ],
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatPnl(double pnl) {
    if (pnl.abs() >= 1000) {
      return '${(pnl / 1000).toStringAsFixed(1)}K';
    }
    return pnl.toStringAsFixed(0);
  }
}