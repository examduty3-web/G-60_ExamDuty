import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 🚨 NEW IMPORT FOR ROLE CHECK
import 'package:cloud_firestore/cloud_firestore.dart'; 

import 'login_screen.dart';
import 'dashboard_screen.dart'; 
import 'firebase_options.dart';

// 🚨 NEW HELPER FUNCTION: Fetch user role from Firestore
Future<String> _fetchUserRole(String uid) async {
  // Use the same logic as in login_screen.dart
  try {
    final doc = await FirebaseFirestore.instance.collection('user_roles').doc(uid).get();
    
    if (doc.exists) {
      final role = doc.data()?['role'] as String?;
      return role ?? 'Guest'; 
    }
    return 'Guest';
  } catch (e) {
    print('Error fetching role on startup: $e');
    return 'Guest'; 
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  
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
        stream: FirebaseAuth.instance.authStateChanges(),
        
        builder: (context, snapshot) {
          // 1. Initial Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Logged In State: User is not null
          if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            
            // 🚨 NEW: Use FutureBuilder to fetch the role asynchronously
            return FutureBuilder<String>(
              future: _fetchUserRole(user.uid),
              builder: (context, roleSnapshot) {
                // Show loading spinner while fetching the role
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // Get the role (or default to 'Guest' if fetch failed)
                final String userRole = roleSnapshot.data ?? 'Guest';
                
                // Derive username
                final String userName = user.displayName ?? user.email!.split('@')[0];

                // Render DashboardScreen with all required parameters
                return DashboardScreen( 
                  userName: userName, 
                  userEmail: user.email!,
                  userRole: userRole, // 🚨 PASSED THE FETCHED ROLE
                );
              },
            );
          }

          // 3. Logged Out State: If user is null, show the Login Screen
          return const LoginScreen();
        },
      ),
    );
  }
}