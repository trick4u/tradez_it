

import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: () {}),
          IconButton(icon: Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: Center(child: Text('Reports Page', style: TextStyle(fontSize: 24))),
    );
  }
}
