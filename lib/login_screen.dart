import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

import 'admin_login.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const String allowedDomain = '@pilani.bits-pilani.ac.in';

  bool _isLoading = false;

  // 🚨 NEW LOGIC: Forgot Password Function
  Future<void> _onForgotPassword() async {
    final String email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty || !email.endsWith(allowedDomain)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your official BITS email to reset password.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Reset Link Sent"),
            content: Text("A password reset link has been sent to $email. Please check your inbox."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Error sending reset email")),
        );
      }
    }
  }

  // 🛠️ HELPER FUNCTION: Fetch user role (Your Original)
  Future<String> _fetchUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('user_roles').doc(uid).get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        return role ?? 'Guest'; 
      }
      return 'Guest'; 
    } catch (e) {
      print('Error fetching role: $e');
      return 'Guest';
    }
  }

  void _onAdminTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  // 🛠️ SIGN IN LOGIC (Your Original)
  Future<void> _onSignIn(BuildContext context) async {
    final String email = _emailController.text.trim().toLowerCase();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    if (!email.contains('@') || !email.endsWith(allowedDomain)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use your official BITS Pilani email (…@pilani.bits-pilani.ac.in)'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCred.user;

      if (user == null) {
        throw FirebaseAuthException(
            code: 'NO_USER', message: 'Sign-in succeeded but no user was returned.');
      }
      
      final String userRole = await _fetchUserRole(user.uid); 
      
      final String userName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!
          : (email.contains('@') ? email.split('@')[0] : email);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userName: userName,
              userEmail: user.email ?? email,
              userRole: userRole,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign-in failed.';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        default:
          message = e.message ?? 'Sign-in failed: ${e.code}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (Retained)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF1E2CF0), Color(0xFF6C0AF4)],
              ),
            ),
          ),
          // Admin logo image (Retained)
          Positioned(
            top: 22,
            left: 14,
            child: InkWell(
              onTap: () => _onAdminTap(context),
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  Image.asset('assets/admin_logo.png', width: 38, height: 38, fit: BoxFit.contain),
                  const SizedBox(height: 1),
                  const Text("Admin?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                ],
              ),
            ),
          ),
          // BITS logo (Retained)
          Positioned(
            top: 15,
            right: 15,
            child: Image.asset('assets/bits_logo.png', width: 80, height: 85, fit: BoxFit.contain),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 17, offset: Offset(0, 7))],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C0AF4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C0AF4).withOpacity(0.17),
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(child: Icon(Icons.school_rounded, color: Colors.white, size: 42)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('ExamDuty+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 0.15)),
                  const SizedBox(height: 7),
                  const Text('Unified Exam-Duty Management Platform', style: TextStyle(color: Color(0xFFE0E2EB), fontSize: 13.5)),
                  const SizedBox(height: 22),
                  // Login Card (Retained all original styling)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.89,
                    padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 6))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BITS Email ID', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF686868), fontSize: 13.5)),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'yourname@pilani.bits-pilani.ac.in',
                            isDense: true,
                            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C0AF4)),
                            filled: true,
                            fillColor: const Color(0xFFF4F6FB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                        const SizedBox(height: 13),
                        const Text('Password', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF686868), fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Enter Your Password',
                            isDense: true,
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6C0AF4)),
                            filled: true,
                            fillColor: const Color(0xFFF4F6FB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                // 🚨 UPDATED: Now linked to Forgot Password Logic
                                onPressed: _onForgotPassword, 
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Color(0xFF6C0AF4), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _onSignIn(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C0AF4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 3,
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 20, child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 11),
                        const Center(child: Text('For faculty and staff only', style: TextStyle(color: Color(0xFF929090), fontSize: 13))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}