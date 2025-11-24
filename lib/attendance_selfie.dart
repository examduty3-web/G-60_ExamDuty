import 'package:flutter/material.dart';
import 'exam_formalities.dart';

class AttendanceSelfieScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const AttendanceSelfieScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  static const Color blueLeft = Color(0x9F1E2CF0);    // #1E2CF0, 62% opacity for gradient
  static const Color purpleRight = Color(0x946C0AF4); // #6C0AF4, 58% opacity for gradient

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBarRounded(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top Colored Bar with White Back Arrow and right-aligned ExamDuty+ + Cap Icon
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 110,
                  color: const Color(0xFF5335EA),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32, left: 9, right: 18),
                  child: Row(
                    children: [
                      // Large white back arrow (icon only)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ExamFormalitiesScreen(
                                userName: userName, userEmail: userEmail),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // "ExamDuty+" + Cap Icon (right-aligned, in order)
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
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
                            child: const Icon(Icons.school_rounded, color: Colors.white, size: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Subject Card (same as center details)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      blueLeft,
                      purpleRight,
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
            // Main card content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Color(0xFFBEBEC7), width: 1),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Attendance Selfie",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Capture a geo-tagged selfie to mark your attendance for exam duty",
                              style: TextStyle(fontSize: 13.2, color: Colors.black54),
                            ),
                            const SizedBox(height: 13),
                            Center(
                              child: Container(
                                width: 168,
                                height: 116,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF6F6FB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Color(0xFFD3D3DE), width: 1.4, style: BorderStyle.solid),
                                ),
                                child: InkWell(
                                  onTap: () { /* Add camera logic here */ },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.camera_alt_rounded, size: 38, color: Color(0xFFB0B2BC)),
                                      SizedBox(height: 8),
                                      Text(
                                        "Take a selfie",
                                        style: TextStyle(fontSize: 15, color: Color(0xFF80819C)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFE8F2FF),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: Color(0xFFA4C7EA), width: 1.0),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(Icons.tips_and_updates_rounded, color: Color(0xFF288AD6), size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        "Tips for a good selfie:",
                                        style: TextStyle(
                                          color: Color(0xFF288AD6),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text("• Ensure good lighting and clear visibility", style: TextStyle(fontSize: 13.1)),
                                  Text("• Face the camera directly", style: TextStyle(fontSize: 13.1)),
                                  Text("• Remove sunglasses or masks if possible", style: TextStyle(fontSize: 13.1)),
                                  Text("• Location will be automatically captured", style: TextStyle(fontSize: 13.1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
          Icon(icon, color: Color(0xFF196BDE), size: 28),
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
