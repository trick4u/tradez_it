import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tradez_it/presentation/main_screen.dart';
import 'package:tradez_it/widgets/trading_calendar_widget.dart';

import 'main_api_client.dart';
import 'widgets/dashboard_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
