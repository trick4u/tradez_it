

import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Center(child: Text('Notifications Page', style: TextStyle(fontSize: 24))),
    );
  }
}