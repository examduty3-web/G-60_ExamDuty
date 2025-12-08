import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';
// 🚨 NEW IMPORT: Firebase Authentication is necessary for sign-in
import 'package:firebase_auth/firebase_auth.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // 🚨 NEW: State variable for loading and form key for validation
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  void _onNotAdminTap(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // 🚨 UPDATED: Handles secure sign-in and navigation
  void _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    try {
      // 1. Perform Secure Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (!mounted) return;

      if (user != null) {
        // 2. Derive user details for the dashboard
        final String userName = user.displayName ?? (user.email?.split('@')[0] ?? 'Admin');
        final String userEmail = user.email ?? email;

        // 3. Navigate to Dashboard (Role check happens INSIDE AdminDashboardScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(
              userName: userName,
              userEmail: userEmail,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      
      // 4. Handle specific Firebase errors (e.g., wrong password, user not found)
      String message = 'Sign in failed.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF1E2CF0),
                  Color(0xFF6C0AF4),
                ],
              ),
            ),
          ),
          // Top left: Not Admin logo image (NO circle, NO border), text below
          Positioned(
            top: 22,
            left: 14,
            child: InkWell(
              onTap: () => _onNotAdminTap(context),
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  Image.asset(
                    'assets/not_admin_logo.png', // <--- your file
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    "Not Admin?",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Top right: Institute logo
          Positioned(
            top: 22,
            right: 15,
            child: Image.asset(
              'assets/bits_logo.png',
              height: 52,
              fit: BoxFit.contain,
            ),
          ),
          // Center login form
          Center(
            child: SingleChildScrollView(
              child: Form( // 🚨 Wrap content in Form for validation
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 17,
                            offset: Offset(0, 7),
                          ),
                        ],
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
                        child: const Center(
                          child: Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'ExamDuty+',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        letterSpacing: 0.15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Unified Exam-Duty Management Platform',
                      style: TextStyle(
                        color: Color(0xFFE0E2EB),
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    // ADMIN login card
                    Container(
                      width: MediaQuery.of(context).size.width * 0.89,
                      padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Email ID',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF686868),
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 7),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'yourname@pilani.bits-pilani.ac.in',
                              isDense: true,
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C0AF4)),
                              filled: true,
                              fillColor: const Color(0xFFF4F6FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                          const SizedBox(height: 13),
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF686868),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter Your Password',
                              isDense: true,
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6C0AF4)),
                              filled: true,
                              fillColor: const Color(0xFFF4F6FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF6C0AF4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              // 🚨 Call the async sign-in method
                              onPressed: _isLoading ? null : _onSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C0AF4),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 3,
                              ),
                              child: _isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 11),
                          const Center(
                            child: Text(
                              'For faculty and staff only',
                              style: TextStyle(
                                color: Color(0xFF929090),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}