import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';

import '../data/models/trade_data_model.dart';
import '../main_api_client.dart';

class TradingCalendarWidget extends StatefulWidget {
  const TradingCalendarWidget({super.key});

  @override
  State<TradingCalendarWidget> createState() => _TradingCalendarWidgetState();
}

class _TradingCalendarWidgetState extends State<TradingCalendarWidget> {
  @override
  Widget build(BuildContext context) {
    final mainApiClient = Get.find<MainApiClient>();
    final controller = Get.put(
      CalendarController(
        mainApiClient: mainApiClient,
        accountId: "c64deeec-d85d-4a02-88d3-1530956fccaf",
      ),
    );
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Color(0xFF1E2329)),
        child: Column(
          children: [
            // Header with month and navigation buttons wrapped in Obx for reactiveness
            Obx(() => buildHeader(controller)),

            // Weekday headers don't depend on state so no Obx needed
            buildWeekdayHeaders(),

            
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return buildCalendarGrid(controller);
            }),
          ],
        ),
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
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.8,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 42, // 6 weeks * 7 days
        itemBuilder: (context, index) {
          final dayOffset = index - startingWeekday;
          if (dayOffset < 0 || dayOffset >= daysInMonth) {
            return Container(); // empty days outside current month
          }
          final day = dayOffset + 1;
          final dateKey = _formatDateKey(
            DateTime(currentMonth.year, currentMonth.month, day),
          );
          final TradeData? tradeData = controller.trades[dateKey];
          return buildDayTile(day, tradeData);
        },
      ),
    );
  }

  Widget buildDayTile(int day, TradeData? tradeData) {
    Color backgroundColor = const Color(0xFF2B3139);
    Color textColor = Colors.white;

    if (tradeData != null) {
      backgroundColor = tradeData.dailyPnl >= 0
          ? const Color(0xFF0ECB81) // Green for profit
          : const Color(0xFFF6465D); // Red for loss
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          // Main content
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
          // Notes icon
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