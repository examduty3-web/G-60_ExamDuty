import 'package:flutter/material.dart';
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

  void _onAdminTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  void _onSignIn(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final userName = email.contains('@') ? email.split('@')[0] : email;

    // For demo, just allow any non-empty credentials (add proper validation for real use!)
    if (email.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            userName: userName,
            userEmail: email,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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
          // Top left: Admin logo image
          Positioned(
            top: 22,
            left: 14,
            child: InkWell(
              onTap: () => _onAdminTap(context),
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  Image.asset(
                    'assets/admin_logo.png', // Your admin logo file (transparent)
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    "Admin?",
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
          // Top right: Institute/BITS logo
          Positioned(
            top: 22,
            right: 15,
            child: Image.asset(
              'assets/bits_logo.png',
              height: 45,
              fit: BoxFit.contain,
            ),
          ),
          // Centered login form
          Center(
            child: SingleChildScrollView(
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
                  // Login Card
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
                          'BITS Email ID',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF686868),
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _emailController,
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
                            onPressed: () => _onSignIn(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C0AF4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
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
        ],
      ),
    );
  }
}
