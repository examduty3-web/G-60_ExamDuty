import 'package:flutter/material.dart';

class MyProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole; // <-- MUST BE HERE

  const MyProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, // <-- MUST BE HERE
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile (WIP)')),
      body: Center(
        child: Text('My Profile Screen - Role: $userRole'),
      ),
    );
  }
}