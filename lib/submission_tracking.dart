// submission_tracking_screen.dart
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

// --- DATA MODEL ---
class SubmissionData {
  final String userId;
  final String name; // This field holds the display name (Name OR Email)
  final String email;
  final String userRole; 
  final String subjectName; 
  
  // Status flags
  final bool attendanceSubmitted;
  final bool invigilationFormSubmitted;
  final bool feedbackSubmitted;
  
  // URLs/Content for popups
  final String? attendanceUrl; 
  final String? invigilationFileUrl; 
  final String? feedbackContent; 
  
  // Invigilation Form Fields 
  final String? examDate;
  final String? examSlot;
  final String? examType;
  final int? numStudents;

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
    this.feedbackContent,
    this.examDate,
    this.examSlot,
    this.examType,
    this.numStudents,
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

  // Function to open the URL in a browser/external app 
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

  // ---------------- INTERACTIVE POPUPS ----------------

  // Function to show the Attendance Image
  void _showImageDialog(BuildContext context, String? imageUrl, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Attendance Proof: $userName"),
        content: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 200, 
                    child: Center(child: CircularProgressIndicator())
                  );
                },
              )
            : const SizedBox(height: 50, child: Center(child: Text("Attendance image not found."))),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Close")),
        ],
      ),
    );
  }

  // Function to show the Feedback Content
  void _showFeedbackDialog(BuildContext context, String? content, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Feedback from $userName"),
        content: SingleChildScrollView(
          child: Text(content ?? "No detailed feedback content available."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Close")),
        ],
      ),
    );
  }

  // NEW DIALOG: Shows Invigilation Form Data + File Link
  void _showInvigilationFormDialog(BuildContext context, SubmissionData data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Invigilation Form: ${data.name}"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              // Form Details
              _detailRow("Date:", data.examDate ?? 'N/A'),
              _detailRow("Slot:", data.examSlot ?? 'N/A'),
              _detailRow("Type:", data.examType ?? 'N/A'),
              _detailRow("Students:", data.numStudents?.toString() ?? 'N/A'),
              const Divider(height: 20),

              // File Download Link
              if (data.invigilationFormSubmitted && data.invigilationFileUrl != null)
                TextButton.icon(
                  icon: const Icon(Icons.file_present_rounded),
                  label: const Text("View/Download Uploaded Form"),
                  onPressed: () => _launchUrl(context, data.invigilationFileUrl),
                )
              else
                const Text("Uploaded file is missing or submission is pending."),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Close")),
        ],
      ),
    );
  }
  
  // Helper for the Dialog content
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 8),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // ---------------- DATA FETCHING LOGIC (Final Working Version - Multi-Collection Merge) ----------------

  Future<List<SubmissionData>> _fetchLiveSubmissions() async {
    final firestore = FirebaseFirestore.instance;
    final Map<String, SubmissionData> submissionMap = {};

    // --- 0. PRE-FETCH ALL STAFF (Source of Truth for User List/Name/Role) ---
    final rolesSnapshot = await firestore.collection('user_roles').get();
    final Map<String, Map<String, dynamic>> userRoles = {};
    for (var doc in rolesSnapshot.docs) {
      userRoles[doc.id] = doc.data();
    }
    
    // --- Initialize the Submission Map with ALL USERS ---
    for (final userId in userRoles.keys) {
      final profile = userRoles[userId]!;
      
      // FIX: Name Fallback (Name OR userName OR Email)
      String profileName = profile['name'] as String? ?? profile['userName'] as String? ?? '';
      String profileEmail = profile['email'] as String? ?? 'N/A Email';
      
      // Ensure we display Email if Name is missing
      String finalDisplayName = (profileName.isEmpty) ? profileEmail : profileName;


      submissionMap[userId] = SubmissionData(
        userId: userId,
        name: finalDisplayName, 
        email: profileEmail, 
        userRole: profile['role'] as String? ?? 'Observer',
        subjectName: 'No Duty Data', 
        
        // Statuses are initialized to false/pending
        attendanceSubmitted: false,
        invigilationFormSubmitted: false,
        feedbackSubmitted: false,
      );
    }
    
    // --- 1. Merge INVIGILATION Data (from /exam_submissions) ---
    // This collection holds the Invigilation form status and the Duty details.
    final submissionsSnapshot = await firestore.collection('exam_submissions').get();

    for (final doc in submissionsSnapshot.docs) {
      final data = doc.data();
      final String userId = doc.id;
      final dynamic numStudentsRaw = data['numStudents'];
      
      if (submissionMap.containsKey(userId)) {
          final existing = submissionMap[userId]!;

          // Invigilation status is read from here
          bool invigilationSub = data['invigilationFormSubmitted'] == true;
          
          // Update the existing record in the map
          submissionMap[userId] = SubmissionData(
            userId: userId,
            name: existing.name, 
            email: existing.email,
            userRole: data['userRole'] as String? ?? existing.userRole, 
            subjectName: data['examType'] as String? ?? 'N/A Subject',

            // Statuses and URLs (Attendance/Feedback status will be overwritten next)
            attendanceSubmitted: existing.attendanceSubmitted, // Keep old status for now
            attendanceUrl: null, // Reset attendance URL as it's coming from /exam_duties
            invigilationFormSubmitted: invigilationSub, 
            invigilationFileUrl: data['invigilationFileUrl'] as String?,
            
            // Invigilation Form Fields 
            examDate: data['examDate'] as String?,
            examSlot: data['examSlot'] as String?,
            examType: data['examType'] as String?,
            numStudents: numStudentsRaw is int ? numStudentsRaw : (numStudentsRaw is String ? int.tryParse(numStudentsRaw) : null),
            
            feedbackSubmitted: existing.feedbackSubmitted, // Keep old status for now
            feedbackContent: null,
          );
      }
    }


    // --- 2. Merge ATTENDANCE Data (from /exam_duties) ---
    // Look up the LATEST attendance record for each user.
    final attendanceSnapshot = await firestore.collection('exam_duties').get();
    final Map<String, Map<String, dynamic>> attendanceDataMap = {};
    
    // Simplification: We need the LATEST attendance document for the URL/Status
    // We group by userId and find the latest timestamp, or just grab the first one if we assume only one attendance per duty is relevant.
    for (final doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final String? userId = data['userId'] as String?;
        if (userId != null && submissionMap.containsKey(userId)) {
            // Assume the main attendance fields are nested under 'attendance'
            final attendanceDetails = data['attendance'] as Map<String, dynamic>?;
            if (attendanceDetails != null) {
              // Store the URL and mark status as true if a record exists
              attendanceDataMap[userId] = {
                  'attendanceSubmitted': true,
                  'attendanceUrl': attendanceDetails['selfieUrl'] as String?,
              };
            }
        }
    }
    
    // --- 3. Merge FEEDBACK Data (from /examFeedbacks) ---
    final feedbackSnapshot = await firestore.collection('examFeedbacks').get();
    final Map<String, Map<String, dynamic>> feedbackDataMap = {};
    for (final doc in feedbackSnapshot.docs) {
        final data = doc.data();
        final String? userId = data['userId'] as String?;
        if (userId != null) {
            feedbackDataMap[userId] = data;
        }
    }

    // --- Final List Merge ---
    final List<SubmissionData> finalSubmissions = [];

    for (final submission in submissionMap.values) {
        // Create the final merged object by combining all three sources
        
        final isAttendance = attendanceDataMap.containsKey(submission.userId);
        final attendanceUrl = isAttendance ? attendanceDataMap[submission.userId]!['attendanceUrl'] as String? : null;

        final isFeedback = feedbackDataMap.containsKey(submission.userId);
        final feedbackContent = isFeedback ? feedbackDataMap[submission.userId]!['suggestions'] as String? 
                                          : (isFeedback ? feedbackDataMap[submission.userId]!['feedbackText'] as String? : null);
        
        final updatedSubmission = SubmissionData(
            userId: submission.userId,
            name: submission.name,
            email: submission.email,
            userRole: submission.userRole,
            subjectName: submission.subjectName,
            
            // --- MERGED STATUSES ---
            attendanceSubmitted: isAttendance,
            attendanceUrl: attendanceUrl,
            
            invigilationFormSubmitted: submission.invigilationFormSubmitted,
            invigilationFileUrl: submission.invigilationFileUrl,
            
            feedbackSubmitted: isFeedback, 
            feedbackContent: feedbackContent,
            
            // Form fields from /exam_submissions
            examDate: submission.examDate,
            examSlot: submission.examSlot,
            examType: submission.examType,
            numStudents: submission.numStudents,
        );
        finalSubmissions.add(updatedSubmission);
    }
    
    // --- 4. Return Final List ---
    return finalSubmissions; 
  }


  // ---------------- UI BUILDERS & WIDGETS ----------------

  Widget _buildBottomNav(BuildContext context) {
    // ... (rest of the bottom nav code is unchanged)
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

  Widget _header(BuildContext context) {
    return Container(
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.school_rounded, color: primaryPurple, size: 24), 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
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
                fontSize: 14.0, 
                color: Colors.black87, 
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              size: 18, 
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 14.0, 
                color: color,
                fontWeight: FontWeight.w500, 
                decoration: onTap != null && status != 'Not Applicable' ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // CARD WIDGET: Displays User Role, Email, and File Links
  Widget _submissionListTile(BuildContext context, SubmissionData data) {
    
    // Check if the user is required to submit the Invigilation Form
    final bool isInvigilationRequired = data.userRole.toLowerCase() == 'superproctor';
    
    final bool formCompleted = isInvigilationRequired ? data.invigilationFormSubmitted : true;

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Name of the Subject
                      Text(
                        "Name of the Subject: ${data.subjectName}",
                        style: const TextStyle(
                          fontSize: 14.0, 
                          color: darkGreyText, 
                        ),
                      ),
                      const SizedBox(height: 5),
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
            const SizedBox(height: 10),
            
            // SUBMISSION TRACKING ROWS
            // 1. Attendance/Selfie - ON TAP: SHOW IMAGE DIALOG
            _submissionRow(
              "Attendance",
              data.attendanceSubmitted ? "Submitted" : "Pending", 
              data.attendanceSubmitted ? Icons.check_circle_outline : Icons.schedule_outlined,
              data.attendanceSubmitted ? statusSubmittedColor : statusPendingColor,
              data.attendanceSubmitted 
                ? () => _showImageDialog(context, data.attendanceUrl, data.name)
                : null,
            ),
            const SizedBox(height: 10), 
            
            // 2. Feedback - ON TAP: SHOW FEEDBACK CONTENT DIALOG
            _submissionRow(
              "Feedback",
              data.feedbackSubmitted ? "Submitted" : "Pending",
              data.feedbackSubmitted ? Icons.check_circle_outline : Icons.schedule_outlined,
              data.feedbackSubmitted ? statusSubmittedColor : statusPendingColor,
              data.feedbackSubmitted 
                ? () => _showFeedbackDialog(context, data.feedbackContent, data.name)
                : null,
            ),
            const SizedBox(height: 10),

            // 3. Invigilation Form (Conditional) - ON TAP: SHOW FORM DETAILS + FILE LINK
            if (isInvigilationRequired)
              _submissionRow(
                "Invigilation Form", 
                data.invigilationFormSubmitted ? "Submitted" : "Pending",
                data.invigilationFormSubmitted ? Icons.check_circle_outline : Icons.schedule_outlined,
                data.invigilationFormSubmitted ? statusSubmittedColor : statusPendingColor,
                data.invigilationFormSubmitted 
                  ? () => _showInvigilationFormDialog(context, data) 
                  : null,
              )
            else
              // Display 'Not Applicable' for roles not requiring the form (e.g., Observer)
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
      backgroundColor: lightGreyBackground,
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
                    // Display the error message clearly for admin diagnosis
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        'Error loading submissions: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ));
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

                  return Column(
                    children: [
                      _pill(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: submissions.length,
                          itemBuilder: (context, index) {
                            return _submissionListTile(context, submissions[index]);
                          },
                        ),
                      ),
                    ],
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

// ---------------- HELPER WIDGETS ----------------

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
          Icon(
            icon,
            color: const Color(0xFF196BDE),
            size: 28,
          ),
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

class _ExamTypeChip extends StatelessWidget {
  const _ExamTypeChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
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
    );
  }
}