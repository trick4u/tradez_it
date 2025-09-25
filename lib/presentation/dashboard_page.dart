import 'package:flutter/material.dart';

import '../widgets/daily_pnl_chart.dart';
import '../widgets/dashBoard_widget.dart';
import '../widgets/trading_calendar_widget.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
   final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('Option 1'), value: 1),
              PopupMenuItem(child: Text('Option 2'), value: 2),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        key: PageStorageKey('dashboard-scroll'),
         controller: _scrollController,
        child: Column(
          children: [
            DashboardWidget(),
            DailyPnLChart(),
            TradingCalendarWidget(),
          ],
        ),
      ),
    );
  }
}