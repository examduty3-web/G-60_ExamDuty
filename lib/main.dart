import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';

// For desktop/UI testing, REMOVE Firebase initialization:
void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  runApp(const ExamDutyApp());
}

class ExamDutyApp extends StatelessWidget {
  const ExamDutyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExamDuty+',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
