import 'package:flutter/material.dart';
import 'exam_formalities.dart'; // Adjust import path as needed
import 'dashboard_screen.dart'; // Import for navigating back
import 'bank_details.dart'; 

class CenterDetailsScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole; // 🚨 MUST BE DEFINED

  const CenterDetailsScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, // 🚨 MUST BE REQUIRED
  });

  static const Color fadedPurple = Color(0xFFF3E9FF);
  static const Color iconPurple = Color(0xFF6C0AF4);

  // Helper function to create a MaterialPageRoute, ensuring all data is passed
  MaterialPageRoute _createRoute(Widget targetWidget) {
    return MaterialPageRoute(
      builder: (context) => targetWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBarRounded(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dashboard header
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 110,
                    color: const Color(0xFF5335EA),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32, left: 20, right: 20),
                    child: Row(
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
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // "Name of the Subject" Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xED1E2CF0),
                        Color(0xBF6C0AF4),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(17, 15, 17, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Name of the Subject",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Text(
                              "Exam Type",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: const [
                          Icon(Icons.folder_copy_outlined, color: Colors.white, size: 17),
                          SizedBox(width: 8),
                          Text("Course Code", style: TextStyle(color: Colors.white, fontSize: 13.2)),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: const [
                          Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 7),
                          Text("Date", style: TextStyle(color: Colors.white, fontSize: 13.2)),
                          Spacer(),
                          Icon(Icons.access_time_rounded, color: Colors.white70, size: 16),
                          SizedBox(width: 5),
                          Text("Time", style: TextStyle(color: Colors.white, fontSize: 13.2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // *** Center-aligned Exam Center Details pill & arrow ***
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: fadedPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Black back arrow (navigates to ExamFormalitiesScreen)
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                _createRoute(ExamFormalitiesScreen(
                                  userName: userName,
                                  userEmail: userEmail,
                                  userRole: userRole, // 🚨 PASSING ROLE
                                )),
                              );
                            },
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 23),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Exam Center Details",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Details card: faded purple, all left-aligned, strong curves
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                child: Container(
                  decoration: BoxDecoration(
                    color: fadedPurple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.11),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 21, 18, 21),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _leftDetailRow(Icons.location_on_rounded, 'Centre Name: Name of the Centre\nAddress: Address'),
                      const SizedBox(height: 17),
                      _leftDetailRow(Icons.person_outline_rounded, 'Contact Person: Name'),
                      const SizedBox(height: 17),
                      _leftDetailRow(Icons.phone_rounded, 'Contact Number: xxxxxxx'),
                      const SizedBox(height: 17),
                      _leftDetailRow(Icons.mail_outline_rounded, 'Email ID: email id'),
                    ],
                  ),
                ),
              ),

              // Number of Students card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 11),
                child: Container(
                  decoration: BoxDecoration(
                    color: fadedPurple,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.08),
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 19),
                  child: Row(
                    children: const [
                      Icon(Icons.person_outline_rounded, color: Colors.black87, size: 23),
                      SizedBox(width: 11),
                      Text(
                        "Number of Students: xxx",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.0),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),

              // BITS Pilani logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 23),
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    "assets/bits_pilani.png",
                    width: 135,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // All details left-aligned, icon and label
  Widget _leftDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconPurple, size: 23),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 15.1,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBarRounded(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 3, left: 1, right: 1, bottom: 7),
      decoration: BoxDecoration(
        color: Colors.grey[200]?.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Note: _NavItem widgets will need to be updated to accept and pass userRole if they navigate elsewhere.
          _NavItem(icon: Icons.home_rounded, label: "Home", onTap: () {}),
          _NavItem(icon: Icons.account_balance_rounded, label: "Bank Details", onTap: () {}),
          _NavItem(icon: Icons.account_balance_wallet_rounded, label: "Honorarium Status", onTap: () {}),
          _NavItem(icon: Icons.person_rounded, label: "My Profile", onTap: () {}),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF196BDE), size: 28),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF196BDE),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}