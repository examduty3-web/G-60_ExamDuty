import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

class SubmissionTrackingScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const SubmissionTrackingScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  // ---------------- BOTTOM NAV ----------------
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white, // PURE WHITE BAR
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // HOME (ACTIVE, LAVENDER)
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
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7FF), // lavender
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.home_rounded,
                      color: Color(0xFF5135EA),
                      size: 22,
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Home",
                      style: TextStyle(
                        color: Color(0xFF5135EA),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // MY PROFILE (INACTIVE, LIGHT GREY)
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.person_rounded,
                    color: Color(0xFFA3A3A3),
                    size: 22,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "My Profile",
                    style: TextStyle(
                      color: Color(0xFFA3A3A3),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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

  // ---------------- TOP PILL ----------------
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
          "Submission Tracking",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------------- CARD HELPERS ----------------
  Widget _statusChip(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _submissionRow(
    String label,
    String status,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.3,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _submissionRowPending(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.3,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.error_outline,
          size: 16,
          color: Color(0xFFFF9800),
        ),
        const SizedBox(width: 4),
        const Text(
          "Pending",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }

  Widget _card({
    required String name,
    required String statusLabel,
    required Color statusBg,
    required Color statusText,
    required bool feedbackPending,
    required bool invitationSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Name of the Subject",
                        style: TextStyle(
                          fontSize: 12.3,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Date",
                        style: TextStyle(
                          fontSize: 11.8,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(statusLabel, statusBg, statusText),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              thickness: 0.7,
              color: Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 6),
            _submissionRow(
              "Attendance",
              "Submitted",
              Icons.check_circle_outline,
              const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 5),
            feedbackPending
                ? _submissionRowPending("Feedback")
                : _submissionRow(
                    "Feedback",
                    "Submitted",
                    Icons.check_circle_outline,
                    const Color(0xFF4CAF50),
                  ),
            const SizedBox(height: 5),
            invitationSubmitted
                ? _submissionRow(
                    "Invitation Form",
                    "Submitted",
                    Icons.check_circle_outline,
                    const Color(0xFF4CAF50),
                  )
                : _submissionRow(
                    "Invitation Form",
                    "Not Applicable",
                    Icons.remove_circle_outline,
                    Colors.redAccent,
                  ),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(BuildContext context) {
    return Stack(
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
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _pill(),
                    _card(
                      name: "Dr. Rajesh Kumar",
                      statusLabel: "Complete",
                      statusBg: const Color(0xFFE3F6E9),
                      statusText: const Color(0xFF2E7D32),
                      feedbackPending: false,
                      invitationSubmitted: true, // FIRST BOX SUBMITTED
                    ),
                    _card(
                      name: "Dr. Meera Iyer",
                      statusLabel: "Pending",
                      statusBg: const Color(0xFFFFF3E0),
                      statusText: const Color(0xFFEF6C00),
                      feedbackPending: true,
                      invitationSubmitted: false,
                    ),
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