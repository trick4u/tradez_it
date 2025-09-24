import 'package:flutter/material.dart';

import '../widgets/dashBoard_widget.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.purple,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('Option 1'), value: 1),
              PopupMenuItem(child: Text('Option 2'), value: 2),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          DashboardWidget(),
          Center(
            child: Text('Dashboard Page', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }
}
