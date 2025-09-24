import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/calendar_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/import_trade_controller.dart';
import '../controllers/navigation_sontroller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/reports_controller.dart';
import '../controllers/trade_controller.dart';
import '../main_api_client.dart';
import 'dashboard_page.dart';
import 'trade_page.dart';
import 'profile_page.dart';
import 'import_trade_page.dart';
import 'reports_page.dart';

class MainScreen extends StatelessWidget {
  final NavigationController navController = Get.put(NavigationController(), permanent: true);


  // Initialize other controllers
  final DashBoardController dashBoardController = Get.put(DashBoardController(
      mainApiClient: Get.find<MainApiClient>()
  ), permanent: true);

  final CalendarController calendarController = Get.put(CalendarController(
      mainApiClient: Get.find<MainApiClient>()
  ), permanent: true);
  final TradeController tradeController = Get.put(TradeController(), permanent: true);
  final ImportTradeController importTradeController = Get.put(ImportTradeController(), permanent: true);
  final ReportsController reportsController = Get.put(ReportsController(), permanent: true);
  final ProfileController profileController = Get.put(ProfileController(), permanent: true);

  final List<Widget> pages = [
    DashboardPage(),
    TradePage(),
    ImportTradePage(),
    ReportsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: pages[navController.currentIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navController.currentIndex.value,
          onTap: navController.changePage,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trades'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Import Trades'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
