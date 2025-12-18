import 'package:flutter/material.dart';
import 'admin_login.dart';
import 'submission_tracking.dart';
import 'feedback_summary.dart';
import 'honorarium_summary.dart';
// 🚨 NEW IMPORTS FOR ADMIN CHECK
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole; 

  const AdminDashboardScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // 🚨 State variables for admin verification
  bool _isAdmin = false;
  bool _isLoading = true;

  // Helper to capitalize strings (for display consistency)
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    s = s.toLowerCase();
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  void initState() {
    super.initState();
    // OPTIMIZATION: Trust the role passed from login/main.dart for the initial check
    if (widget.userRole.toLowerCase() == 'admin' || widget.userRole.toLowerCase() == 'super proctor') {
        _isAdmin = true;
        _isLoading = false;
    } else {
        _checkAdminStatus(); // Fallback check to confirm privileges
    }
  }

  // 🚨 Function to check if the current user's UID exists in the 'admins' collection
  void _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('admins') // ⚠️ Ensure this is the correct Admin collection name
            .doc(user.uid)
            .get();

        if (mounted) {
          setState(() {
            _isAdmin = docSnapshot.exists;
          });
        }
      } catch (e) {
        print('Error checking admin status: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text(
          "Are you sure you want to logout?\nYou will be redirected to the login screen.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // 🚨 Firebase Sign Out
              await FirebaseAuth.instance.signOut();
              
              if (!mounted) return;
              Navigator.of(context).pop();
              // Navigate back to the Admin Login Screen (or general Login Screen)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Color(0xFF5335EA), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 29, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 Show loading spinner while checking admin status
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Fallback: If not admin, show an unauthorized message
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
              "You are not authorized to view the admin dashboard.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ),
      );
    }

    // Main Dashboard UI
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top purple area and user info
          Stack(
            children: [
              Container(
                height: 192,
                width: double.infinity,
                color: const Color(0xFF5335EA),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 43),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 51,
                          height: 51,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF5335EA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 21),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "ExamDuty+",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white, size: 26),
                            onPressed: () => _showLogoutDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // User info card - using widget properties
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9180CB),
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.13),
                            blurRadius: 8,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 11),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 7,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/admin_logo.png', // Assuming admin logo
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.5,
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                // 🚨 Display the Admin's role and email
                                '${_capitalize(widget.userRole)} | ${widget.userEmail}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Four action cards
          _actionCard(
            title: "Assign Tasks",
            subtitle: "Assign the roles for Observers & Super Proctors",
            onTap: () {},
          ),
          _actionCard(
            title: "Feedback Summary",
            subtitle: "Feedback of exam center quality and logistics",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackSummaryScreen(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                    userRole: widget.userRole, // 🚨 PASSING ROLE
                  ),
                ),
              );
            },
          ),
          _actionCard(
            title: "Submission Tracking",
            subtitle: "Submission status of invigilation form, feedback & attendance",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubmissionTrackingScreen(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                    userRole: widget.userRole, // 🚨 PASSING ROLE
                  ),
                ),
              );
            },
          ),
          _actionCard(
            title: "Honorarium Summary",
            subtitle: "Submit: Your Accomodation Details",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HonorariumSummaryScreen(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                    userRole: widget.userRole, // 🚨 PASSING ROLE
                  ),
                ),
              );
            },
          ),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: Container(
        // ... (bottom navigation bar implementation is fine)
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8, top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // HOME BUTTON (active)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E5FD),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(height: 7),
                    Icon(Icons.home_rounded, color: Color(0xFF5135EA), size: 25),
                    SizedBox(height: 1),
                    Text(
                      "Home",
                      style: TextStyle(
                        color: Color(0xFF5135EA),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 7),
                  ],
                ),
              ),
            ),
            // MY PROFILE BUTTON (inactive but styled)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(height: 7),
                    Icon(Icons.person_rounded, color: Color(0xFFA3A3A3), size: 25),
                    SizedBox(height: 1),
                    Text(
                      "My Profile",
                      style: TextStyle(
                        color: Color(0xFFA3A3A3),
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}