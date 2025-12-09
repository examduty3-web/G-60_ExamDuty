import 'package:flutter/material.dart';
import 'attendance_selfie.dart';
import 'invigilation_form.dart';
import 'center_details.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart'; 
import 'feedback_form.dart';
import 'travel_stay.dart';

class ExamFormalitiesScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  // 🚨 REQUIRED PARAMETER
  final String userRole; 

  const ExamFormalitiesScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, // 🚨 CONSTRUCTOR UPDATED
  });

  static const Color blueLeft = Color(0x9F1E2CF0); 
  static const Color purpleRight = Color(0x946C0AF4); 

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?\nYou will be redirected to the login screen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Note: Add Firebase sign-out logic here if implemented.
              // await FirebaseAuth.instance.signOut(); 
              
              if (!context.mounted) return;
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
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
          padding: const EdgeInsets.only(bottom: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top header (Unchanged)
              Stack(
                children: [
                  Container(
                    height: 210,
                    width: double.infinity,
                    color: const Color(0xFF5335EA),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 44),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9180CB),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.13),
                              blurRadius: 8,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: const CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 21,
                                child: Icon(Icons.person, color: Colors.white, size: 28),
                              ),
                            ),
                            const SizedBox(width: 17),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.5,
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  userEmail,
                                  style: const TextStyle(fontSize: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Subject Card (Unchanged)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xED1E2CF0), // blue top (93%)
                        Color(0xBF6C0AF4), // purple bottom (74%)
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
                              fontSize: 15.6,
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
              // Exam Center Details pill...
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 22, right: 22, bottom: 13),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: 37,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          blueLeft,
                          purpleRight,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white, size: 19),
                        const SizedBox(width: 9),
                        const Text(
                          "Exam Center Details",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 15.4,
                          ),
                        ),
                        const SizedBox(width: 9),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.push(
                              context,
                              _createRoute(CenterDetailsScreen(
                                userName: userName,
                                userEmail: userEmail,
                                userRole: userRole, // 🚨 PASSING ROLE
                              )),
                            );
                          },
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Formalities cards grid
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                children: [
                  _FormalitiesCard(
                    icon: Icons.camera_alt_rounded,
                    color: const Color(0xFF9876F4),
                    title: "Attendance Selfie",
                    subtitle: "Submit Your Attendance",
                    onTap: () {
                      Navigator.push(
                        context,
                        _createRoute(AttendanceSelfieScreen(
                          userName: userName,
                          userEmail: userEmail,
                          userRole: userRole, // 🚨 PASSING ROLE
                        )),
                      );
                    },
                  ),
                  _FormalitiesCard(
                    icon: Icons.edit_document,
                    color: const Color(0xFFD67EFF),
                    title: "Invigilation Form",
                    subtitle: "Upload Exam Form",
                    onTap: () {
                      Navigator.push(
                        context,
                        _createRoute(InvigilationFormScreen(
                          userName: userName,
                          userEmail: userEmail,
                          userRole: userRole, // 🚨 PASSING ROLE
                        )),
                      );
                    },
                  ),
                  _FormalitiesCard(
                    icon: Icons.comment_rounded,
                    color: const Color(0xFFE4B852),
                    title: "Feedback",
                    subtitle: "Share Your Exam Duty Feedback",
                    onTap: () {
                      Navigator.push(
                        context,
                        _createRoute(FeedbackFormScreen(
                          userName: userName,
                          userEmail: userEmail,
                          userRole: userRole, // 🚨 PASSING ROLE
                        )),
                      );
                    },
                  ),
                  _FormalitiesCard(
                    icon: Icons.flight_takeoff_rounded,
                    color: const Color(0xFFCE7DD9),
                    title: "Travel & Stay",
                    subtitle: "Submit: Your Accommodation Details",
                    iconTransform: Matrix4.rotationZ(-0.15),
                    onTap: () {
                      Navigator.push(
                        context,
                        _createRoute(TravelStayScreen(
                          userName: userName,
                          userEmail: userEmail,
                          userRole: userRole, // 🚨 PASSING ROLE
                        )),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
          _NavItem(
            icon: Icons.home_rounded,
            label: "Home",
            onTap: () {
              // Return to DashboardScreen, passing the role
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => DashboardScreen(
                    userName: userName,
                    userEmail: userEmail,
                    userRole: userRole, // 🚨 PASSING ROLE
                  ),
                ),
              );
            },
          ),
          _NavItem(icon: Icons.account_balance_rounded, label: "Bank Details", onTap: () {}),
          _NavItem(icon: Icons.account_balance_wallet_rounded, label: "Honorarium Status", onTap: () {}),
          _NavItem(icon: Icons.person_rounded, label: "My Profile", onTap: () {}),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
// ... (The rest of _NavItem remains the same)
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

class _FormalitiesCard extends StatelessWidget {
// ... (The rest of _FormalitiesCard remains the same)
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Matrix4? iconTransform;

  const _FormalitiesCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconTransform,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: Colors.white,
        elevation: 4,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: iconTransform == null
                      ? Icon(icon, color: color, size: 21)
                      : Transform(
                          transform: iconTransform!,
                          alignment: Alignment.center,
                          child: Icon(icon, color: color, size: 21),
                        ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.7,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 23),
              ],
            ),
          ),
        ),
      ),
    );
  }
}