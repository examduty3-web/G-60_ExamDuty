import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED for auth state stream
import 'login_screen.dart';
import 'dashboard_screen.dart'; // REQUIRED for redirection
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  
  // The main app runs the Auth stream logic
  runApp(const ExamDutyApp());
}

class ExamDutyApp extends StatelessWidget {
  const ExamDutyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExamDuty+',
      debugShowCheckedModeBanner: false,
      
      // --- Implementation of User Redirection Logic ---
      home: StreamBuilder<User?>(
        // Listen to the stream that reports if a user is logged in or out
        stream: FirebaseAuth.instance.authStateChanges(),
        
        builder: (context, snapshot) {
          // 1. Loading State: Show a spinner while checking the user's status
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Logged In State: If user data exists (user != null)
          if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            
            // Pass the required parameters (userName, userEmail) to DashboardScreen
            return DashboardScreen( 
              userName: user.displayName ?? user.email!.split('@')[0], 
              userEmail: user.email!,
            );
          }

          // 3. Logged Out State: If user is null, show the Login Screen
          return const LoginScreen();
        },
      ),
    );
  }
}