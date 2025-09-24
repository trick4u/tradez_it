

import 'package:flutter/material.dart';

class ImportTradePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Trades'),
        backgroundColor: Colors.green,
        leading: Icon(Icons.import_export),
      ),
      body: Center(child: Text('Import Trades Page', style: TextStyle(fontSize: 24))),
    );
  }
}