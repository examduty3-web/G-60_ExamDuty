import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'admin_dashboard_screen.dart';

// --- COLOR PALETTE DEFINITION ---
const Color primaryPurple = Color(0xFF5335EA);
const Color secondaryLavender = Color(0xFFEDE7FF);
const Color secondaryGrey = Color(0xFFF5F5F5);
const Color accentGreen = Color(0xFF4CAF50); 
const Color accentOrange = Color(0xFFFF9800); 
const Color darkGreyText = Color(0xFF65657E);
const Color lightGreyBackground = Color(0xFFF0F0F0); 

// --- DATA MODEL PLACEHOLDER ---
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
  final String userRole; 

  const SubmissionTrackingScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, 
  });

  // Function to open the URL in a browser/external app (Unchanged)
  Future<void> _launchUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File URL is missing or invalid.'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid URL format.'), backgroundColor: Colors.red),
        );
        return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: $url')),
      );
    }
  }

  // LOGIC FIX: Fetches ALL user submissions (Unchanged functional logic)
  Future<List<SubmissionData>> _fetchLiveSubmissions() async {
    final firestore = FirebaseFirestore.instance;
    
    final querySnapshot = await firestore.collection('exam_submissions').get();

    final List<SubmissionData> submissions = [];

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      
      final String docId = doc.id;
      final String subName = data['userName'] ?? 'N/A Name'; 
      final String subEmail = data['userEmail'] ?? 'N/A Email';
      final String subRole = data['userRole'] ?? 'Unknown Role';
      final String subjectIdentifier = "Subject: ${data['examType'] ?? 'N/A Type'} | Students: ${data['numStudents'] ?? 'N/A'}"; 

      submissions.add(
        SubmissionData(
          userId: docId,
          name: subName,
          email: subEmail,
          userRole: subRole,
          subjectName: subjectIdentifier,
          
          attendanceSubmitted: data['attendanceSubmitted'] == true,
          invigilationFormSubmitted: data['invigilationFormSubmitted'] == true,
          feedbackSubmitted: data['feedbackSubmitted'] == true || (data['feedbackId'] != null), 
          
          attendanceUrl: data['attendanceFileUrl'], 
          invigilationFileUrl: data['invigilationFileUrl'],
        ),
      );
    }
    
    return submissions; 
  }

  // ---------------- BOTTOM NAV ---------------- (Matches Design)
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
          // HOME (ACTIVE)
          Expanded(
            child: GestureDetector(
              onTap: () {
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
                  color: secondaryLavender, 
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.home_rounded,
                      color: primaryPurple, 
                      size: 22,
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Home",
                      style: TextStyle(
                        color: primaryPurple, 
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
          // MY PROFILE (INACTIVE)
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: secondaryGrey, 
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

  // ---------------- TOP PILL ---------------- (Matches Design)
  Widget _pill() {
    return Container(
      width: 327,
      height: 51,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: primaryPurple,
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

  // ---------------- HEADER ----------------
  // 🚨 DESIGN FIX: Captures the primaryPurple background with white icons/text
  Widget _header(BuildContext context) {
    return Container(
      // CRITICAL FIX: The design shows a solid purple header, NOT white.
      color: primaryPurple, 
      padding: const EdgeInsets.only(top: 32, left: 9, right: 18, bottom: 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white, // White icon against purple
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              const Text(
                "ExamDuty+",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white, // White text against purple
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              // Profile/Logo Container
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  // Purple icon inside white box
                  child: Icon(Icons.school_rounded, color: primaryPurple, size: 24), 
                ),
              ),
            ],
          ),
        ],
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
    // 🚨 DESIGN FIX: Ensure the row text color and font size match
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.0, // Increased size to match design
                color: Colors.black87, // Dark text for the label
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              size: 18, // Slightly larger icon
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 14.0, // Increased size to match design
                color: color,
                fontWeight: FontWeight.w500, // Medium font weight
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // CARD WIDGET: Displays User Role, Email, and File Links
  Widget _submissionListTile(BuildContext context, SubmissionData data) {
    
    final bool isSuperProctor = data.userRole.toLowerCase() == 'superproctor';
    
    final bool isFormApplicable = isSuperProctor;
    final bool formCompleted = isFormApplicable ? data.invigilationFormSubmitted : true;

    final bool isComplete = data.attendanceSubmitted && data.feedbackSubmitted && formCompleted;
    
    final String statusLabel = isComplete ? "Complete" : "Pending";
    // Colors matching the Figma design for the status chips
    final Color cardStatusBg = isComplete ? const Color(0xFFE3F6E9) : const Color(0xFFFEE8B7); 
    final Color cardStatusText = isComplete ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00); 

    // Colors for the individual rows
    final Color statusSubmittedColor = accentGreen;
    final Color statusPendingColor = accentOrange;
    final Color statusNotApplicableColor = const Color(0xFFC70000); 

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Increased vertical padding
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
                      // Name (Role)
                      Text(
                        '${data.name} (${data.userRole})',
                        style: const TextStyle(
                          fontSize: 16.0, // Match design's larger name font
                          fontWeight: FontWeight.bold, // Match design's bold name
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5), // Added space
                      // Name of the Subject
                      Text(
                        "Name of the Subject: ${data.subjectName}",
                        style: const TextStyle(
                          fontSize: 14.0, 
                          color: darkGreyText, 
                        ),
                      ),
                      const SizedBox(height: 5), // Added space
                      const Text(
                        "Date", // Placeholder text for date, as per design
                        style: TextStyle(
                          fontSize: 14.0,
                          color: darkGreyText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Chip (Complete/Pending)
                _statusChip(statusLabel, cardStatusBg, cardStatusText),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              thickness: 0.7,
              color: Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 10), // Increased spacing before rows
            
            // SUBMISSION TRACKING ROWS
            // 1. Attendance/Selfie
            _submissionRow(
              "Attendance",
              data.attendanceSubmitted ? "Submitted" : "Pending", 
              data.attendanceSubmitted ? Icons.check_circle_outline : Icons.schedule_outlined,
              data.attendanceSubmitted ? statusSubmittedColor : statusPendingColor,
              data.attendanceSubmitted 
                ? () => _launchUrl(context, data.attendanceUrl) 
                : null,
            ),
            const SizedBox(height: 10), 
            
            // 2. Feedback
            _submissionRow(
              "Feedback",
              data.feedbackSubmitted ? "Submitted" : "Pending",
              data.feedbackSubmitted ? Icons.check_circle_outline : Icons.schedule_outlined,
              data.feedbackSubmitted ? statusSubmittedColor : statusPendingColor,
              null, 
            ),
            const SizedBox(height: 10),

            // 3. Invigilation Form (Conditional)
            if (isFormApplicable)
              _submissionRow(
                "Invigilation Form", 
                data.invigilationFormSubmitted ? "Submitted" : "Pending",
                data.invigilationFormSubmitted ? Icons.check_circle_outline : Icons.schedule_outlined,
                data.invigilationFormSubmitted ? statusSubmittedColor : statusPendingColor,
                data.invigilationFormSubmitted 
                  ? () => _launchUrl(context, data.invigilationFileUrl) 
                  : null,
              )
            else
              // Display 'Not Applicable' for Observers (Matches Design)
              _submissionRow(
                "Invigilation Form",
                "Not Applicable",
                Icons.do_not_disturb_on_outlined, 
                statusNotApplicableColor, 
                null, 
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyBackground, // Light background
      // Removed safe area from bottom to allow the bottom nav to sit at the edge
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
                    return Column(
                      children: [
                        _pill(),
                        const SizedBox(height: 50),
                        const Center(child: Text("No exam duty submissions found.")),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // The pill needs to be inside the scroll view to handle overflow
                        _pill(),
                        // RENDER ALL LIVE SUBMISSIONS
                        ...submissions.map((data) => _submissionListTile(context, data)).toList(),
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