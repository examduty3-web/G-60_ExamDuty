import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

// --- DATA MODEL PLACEHOLDER ---
// This model defines the structure expected for each submission record fetched from Firestore.
class SubmissionData {
  final String userId;
  final String name;
  final String email;
  final String userRole; 
  final String subjectName;
  
  final bool attendanceSubmitted;
  final bool invigilationFormSubmitted;
  final bool feedbackSubmitted;
  
  final String? attendanceUrl; 
  final String? invigilationFileUrl; 

  SubmissionData({
    required this.userId,
    required this.name,
    required this.email,
    required this.userRole,
    required this.subjectName,
    this.attendanceSubmitted = false,
    this.invigilationFormSubmitted = false,
    this.feedbackSubmitted = false,
    this.attendanceUrl,
    this.invigilationFileUrl,
  });
}

class SubmissionTrackingScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole; // 🚨 ADD THIS LINE

  const SubmissionTrackingScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, // 🚨 ADD THIS LINE
  });

  // 🚨 LIVE DATA FETCHING PLACEHOLDER
  // Replace this with your actual FutureBuilder/StreamBuilder setup later.
  Future<List<SubmissionData>> _fetchLiveSubmissions() async {
    // 💡 TO DO: Implement Firestore logic here.
    // 1. Query the 'exam_duties' collection for all submissions.
    // 2. Map the results into a List<SubmissionData>.
    
    // Returning an empty list for now, ready for integration.
    return []; 
  }

  // ---------------- BOTTOM NAV ----------------
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
                // Navigate back to Admin Dashboard, passing admin details
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminDashboardScreen(
                      userName: userName,
                      userEmail: userEmail,
                      userRole: userRole, 
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
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
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
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _submissionRowPending(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
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
      ),
    );
  }
  
  // 🚨 CARD WIDGET: Displays User Role, Email, and File Links
  Widget _submissionListTile(SubmissionData data) {
    
    // Determine overall status
    final bool isComplete = data.attendanceSubmitted && data.feedbackSubmitted && data.invigilationFormSubmitted;
    
    final String statusLabel = isComplete ? "Complete" : "Pending";
    final Color statusBg = isComplete ? const Color(0xFFE3F6E9) : const Color(0xFFFFF3E0);
    final Color statusText = isComplete ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00);

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
            // TOP ROW: Name, Role, Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 🚨 DISPLAY USER ROLE AND EMAIL
                      Text(
                        'Role: ${data.userRole} | ${data.email}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF5335EA), 
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data.subjectName,
                        style: const TextStyle(
                          fontSize: 12.3,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Date (Placeholder)", 
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
            
            // SUBMISSION TRACKING ROWS
            // 1. Attendance/Selfie
            _submissionRow(
              "Attendance (Selfie)",
              data.attendanceSubmitted ? "View File" : "Pending",
              data.attendanceSubmitted ? Icons.check_circle_outline : Icons.error_outline,
              data.attendanceSubmitted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
              data.attendanceSubmitted ? () {
                debugPrint('Viewing Selfie for ${data.name}: ${data.attendanceUrl}');
              } : null,
            ),
            const SizedBox(height: 5),
            
            // 2. Invigilation Form
            _submissionRow(
              "Invigilation Form (File)",
              data.invigilationFormSubmitted ? "View File" : "Pending",
              data.invigilationFormSubmitted ? Icons.check_circle_outline : Icons.error_outline,
              data.invigilationFormSubmitted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
              data.invigilationFormSubmitted ? () {
                 debugPrint('Viewing Form for ${data.name}: ${data.invigilationFileUrl}');
              } : null,
            ),
            const SizedBox(height: 5),
            
            // 3. Feedback
            _submissionRow(
              "Feedback",
              data.feedbackSubmitted ? "Submitted" : "Pending",
              data.feedbackSubmitted ? Icons.check_circle_outline : Icons.error_outline,
              data.feedbackSubmitted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
              null, // Feedback usually isn't a file to click
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
              child: FutureBuilder<List<SubmissionData>>(
                future: _fetchLiveSubmissions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading data: ${snapshot.error}'));
                  }
                  
                  final submissions = snapshot.data ?? [];
                  
                  if (submissions.isEmpty) {
                    return const Center(child: Text("No exam duty submissions found."));
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _pill(),
                        // 🚨 DYNAMICALLY RENDER LIVE DATA
                        ...submissions.map((data) => _submissionListTile(data)).toList(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}