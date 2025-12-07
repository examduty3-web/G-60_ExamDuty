import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

class HonorariumSummaryScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const HonorariumSummaryScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  Widget _buildBottomNav(BuildContext context) {
    return Container(
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
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminDashboardScreen(
                      userName: userName,
                      userEmail: userEmail,
                    ),
                  ),
                  (route) => false,
                );
              },
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
                    Icon(
                      Icons.home_rounded,
                      color: Color(0xFF5135EA),
                      size: 25,
                    ),
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
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD9D9D9),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(height: 7),
                  Icon(
                    Icons.person_rounded,
                    color: Color(0xFFA3A3A3),
                    size: 25,
                  ),
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
    );
  }

  Widget _pill() {
    return Container(
      width: 327,
      height: 51,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF5335EA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          "Honorarium Summary",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _placeholderCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 110,
                  color: const Color(0xFF5335EA),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 32, left: 9, right: 18),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      const Text(
                        "ExamDuty+",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5335EA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _pill(),
                    _placeholderCard(),
                    const SizedBox(height: 10),
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