

import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green,
        leading: Icon(Icons.person),
      ),
      body: Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
    );
  }
}