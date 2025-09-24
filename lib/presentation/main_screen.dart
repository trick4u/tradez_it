import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/navigation_sontroller.dart';
import 'dashboard_page.dart';
import 'trade_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class MainScreen extends StatelessWidget {
  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> pages = [
    DashboardPage(),
    TradePage(),
    ProfilePage(),
    SettingsPage(),
    NotificationsPage(),
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
