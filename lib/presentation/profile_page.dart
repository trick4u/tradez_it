

import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
    );
  }
}