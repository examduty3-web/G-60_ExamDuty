import 'package:flutter/material.dart';

class HonorariumStatusScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole; // <-- MUST BE HERE

  const HonorariumStatusScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, // <-- MUST BE HERE
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Honorarium Status (WIP)')),
      body: Center(
        child: Text('Honorarium Status Screen - Role: $userRole'),
      ),
    );
  }
}