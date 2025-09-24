

import 'package:flutter/material.dart';

class TradePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trades'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    );
  }
}
