// submission_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'package:geocoding/geocoding.dart'; // 🚨 NEW IMPORT
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
  final String name; 
  final String email;
  final String userRole; 
  final String subjectName; 
  
  final bool attendanceSubmitted;
  final bool invigilationFormSubmitted;
  final bool feedbackSubmitted;
  
  final String? attendanceUrl; 
  final String? attendanceLocation; // To store location address
  final String? invigilationFileUrl; 
  final Map<String, dynamic>? feedbackData; // To store all Q&A pairs
  
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
    this.attendanceLocation,
    this.invigilationFileUrl,
    this.feedbackData,
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

  // 🚨 NEW HELPER: Convert Coordinates to Readable Address
  Future<String> _getAddressFromCoords(double? lat, double? lng) async {
    if (lat == null || lng == null) return "No coordinates available.";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        // Formats: "Street, Sublocality, Locality, PostalCode"
        return "${p.street}, ${p.subLocality}, ${p.locality}, ${p.postalCode}";
      }
    } catch (e) {
      debugPrint("Geocoding Error: $e");
    }
    return "Lat: $lat, Lng: $lng"; // Fallback
  }

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

  void _showImageDialog(BuildContext context, String? imageUrl, String? location, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Attendance: $userName"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                    },
                  )
                : const Text("Attendance image not found."),
            const SizedBox(height: 15),
            const Divider(),
            _detailRow("Location Address:", location ?? "No location details provided."),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, Map<String, dynamic>? fbData, String userName) {
    final List<String> metaDataKeys = ['userId', 'timestamp', 'userName', 'email'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Feedback: $userName"),
        content: SizedBox(
          width: double.maxFinite,
          child: fbData == null || fbData.isEmpty
              ? const Text("No detailed feedback content available.")
              : ListView(
                  shrinkWrap: true,
                  children: fbData.entries.where((e) => !metaDataKeys.contains(e.key)).map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPurple, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text("${entry.value}", style: const TextStyle(fontSize: 14)),
                          const Divider(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showInvigilationFormDialog(BuildContext context, SubmissionData data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Invigilation Form: ${data.name}"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _detailRow("Date:", data.examDate ?? 'N/A'),
              _detailRow("Slot:", data.examSlot ?? 'N/A'),
              _detailRow("Type:", data.examType ?? 'N/A'),
              _detailRow("Students:", data.numStudents?.toString() ?? 'N/A'),
              const Divider(height: 20),
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

  // ---------------- DATA FETCHING LOGIC ----------------

  Future<List<SubmissionData>> _fetchLiveSubmissions() async {
    final firestore = FirebaseFirestore.instance;
    final Map<String, SubmissionData> submissionMap = {};

    final rolesSnapshot = await firestore.collection('user_roles').get();
    for (var doc in rolesSnapshot.docs) {
      final profile = doc.data();
      String profileName = profile['name'] as String? ?? profile['userName'] as String? ?? profile['email'] as String? ?? 'User';
      submissionMap[doc.id] = SubmissionData(
        userId: doc.id,
        name: profileName, 
        email: profile['email'] as String? ?? '', 
        userRole: profile['role'] as String? ?? 'Observer',
        subjectName: 'No Duty Data', 
      );
    }
    
    final submissionsSnapshot = await firestore.collection('exam_submissions').get();
    for (final doc in submissionsSnapshot.docs) {
      final data = doc.data();
      final String userId = doc.id;
      if (submissionMap.containsKey(userId)) {
          final existing = submissionMap[userId]!;
          submissionMap[userId] = SubmissionData(
            userId: userId, name: existing.name, email: existing.email, userRole: existing.userRole,
            subjectName: data['examType'] as String? ?? 'N/A Subject',
            invigilationFormSubmitted: data['invigilationFormSubmitted'] == true,
            invigilationFileUrl: data['invigilationFileUrl'] as String?,
            examDate: data['examDate'] as String?, examSlot: data['examSlot'] as String?,
            examType: data['examType'] as String?, numStudents: data['numStudents'] is int ? data['numStudents'] : int.tryParse(data['numStudents'].toString()),
          );
      }
    }

    final attendanceSnapshot = await firestore.collection('exam_duties').get();
    final Map<String, Map<String, dynamic>> attendanceDataMap = {};
    for (final doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final String? uId = data['userId'] as String?;
        if (uId != null) {
            final attendanceDetails = data['attendance'] as Map<String, dynamic>?;
            if (attendanceDetails != null) {
              // 🚨 LOGIC: Get Address or Convert Lat/Lng
              String finalAddress = attendanceDetails['locationAddress'] ?? "Processing...";
              
              if (attendanceDetails['locationAddress'] == null && 
                  attendanceDetails['latitude'] != null && 
                  attendanceDetails['longitude'] != null) {
                finalAddress = await _getAddressFromCoords(
                  (attendanceDetails['latitude'] as num).toDouble(), 
                  (attendanceDetails['longitude'] as num).toDouble()
                );
              }

              attendanceDataMap[uId] = {
                  'submitted': true,
                  'url': attendanceDetails['selfieUrl'],
                  'loc': finalAddress,
              };
            }
        }
    }
    
    final feedbackSnapshot = await firestore.collection('examFeedbacks').get();
    final Map<String, Map<String, dynamic>> feedbackDataMap = {};
    for (final doc in feedbackSnapshot.docs) {
        final data = doc.data();
        final String? uId = data['userId'] as String?;
        if (uId != null) {
            feedbackDataMap[uId] = data;
        }
    }

    final List<SubmissionData> finalSubmissions = [];
    for (final submission in submissionMap.values) {
        final att = attendanceDataMap[submission.userId];
        final fb = feedbackDataMap[submission.userId];
        
        finalSubmissions.add(SubmissionData(
            userId: submission.userId, name: submission.name, email: submission.email,
            userRole: submission.userRole, subjectName: submission.subjectName,
            attendanceSubmitted: att != null,
            attendanceUrl: att?['url'],
            attendanceLocation: att?['loc'],
            invigilationFormSubmitted: submission.invigilationFormSubmitted,
            invigilationFileUrl: submission.invigilationFileUrl,
            feedbackSubmitted: fb != null, 
            feedbackData: fb,
            examDate: submission.examDate, examSlot: submission.examSlot,
            examType: submission.examType, numStudents: submission.numStudents,
        ));
    }
    return finalSubmissions; 
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, -2))]),
      child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => AdminDashboardScreen(userName: userName, userEmail: userEmail, userRole: userRole)), (r) => false),
            child: Container(height: 52, decoration: BoxDecoration(color: secondaryLavender, borderRadius: BorderRadius.circular(24)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.home_rounded, color: primaryPurple, size: 22), Text("Home", style: TextStyle(color: primaryPurple, fontSize: 12.5, fontWeight: FontWeight.w600))])))),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 52, decoration: BoxDecoration(color: secondaryGrey, borderRadius: BorderRadius.circular(24)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.person_rounded, color: Color(0xFFA3A3A3), size: 22), Text("My Profile", style: TextStyle(color: Color(0xFFA3A3A3), fontSize: 12.5, fontWeight: FontWeight.w600))]))),
      ]));
  }

  Widget _header(BuildContext context) {
    return Container(color: primaryPurple, padding: const EdgeInsets.only(top: 32, left: 9, right: 18, bottom: 10),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32), onPressed: () => Navigator.pop(context)),
        const Spacer(),
        const Text("ExamDuty+", style: TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Container(width: 43, height: 43, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)), child: const Center(child: Icon(Icons.school_rounded, color: primaryPurple, size: 24))),
      ]));
  }

  Widget _pill() {
    return Container(width: double.infinity, height: 51, margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(color: primaryPurple, borderRadius: BorderRadius.circular(15)),
      child: const Center(child: Text("Submission Tracking", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))));
  }

  Widget _submissionListTile(BuildContext context, SubmissionData data) {
    final bool isInvigilationRequired = data.userRole.toLowerCase() == 'superproctor';
    final bool formCompleted = isInvigilationRequired ? data.invigilationFormSubmitted : true;
    final bool isComplete = data.attendanceSubmitted && data.feedbackSubmitted && formCompleted;
    final String statusLabel = isComplete ? "Complete" : "Pending";
    final Color cardStatusBg = isComplete ? const Color(0xFFE3F6E9) : const Color(0xFFFEE8B7); 
    final Color cardStatusText = isComplete ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00); 

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${data.name} (${data.userRole})', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Subject: ${data.subjectName}", style: const TextStyle(fontSize: 14.0, color: darkGreyText)),
            ])),
            _statusChip(statusLabel, cardStatusBg, cardStatusText),
          ]),
          const Divider(height: 25, thickness: 0.7),
          _submissionRow("Attendance", data.attendanceSubmitted ? "Submitted" : "Pending", data.attendanceSubmitted ? Icons.check_circle_outline : Icons.schedule_outlined, data.attendanceSubmitted ? accentGreen : accentOrange, 
            data.attendanceSubmitted ? () => _showImageDialog(context, data.attendanceUrl, data.attendanceLocation, data.name) : null),
          const SizedBox(height: 10), 
          _submissionRow("Feedback", data.feedbackSubmitted ? "Submitted" : "Pending", data.feedbackSubmitted ? Icons.check_circle_outline : Icons.schedule_outlined, data.feedbackSubmitted ? accentGreen : accentOrange, 
            data.feedbackSubmitted ? () => _showFeedbackDialog(context, data.feedbackData, data.name) : null),
          const SizedBox(height: 10),
          if (isInvigilationRequired)
            _submissionRow("Invigilation Form", data.invigilationFormSubmitted ? "Submitted" : "Pending", data.invigilationFormSubmitted ? Icons.check_circle_outline : Icons.schedule_outlined, data.invigilationFormSubmitted ? accentGreen : accentOrange, 
              data.invigilationFormSubmitted ? () => _showInvigilationFormDialog(context, data) : null)
          else
            _submissionRow("Invigilation Form", "Not Applicable", Icons.do_not_disturb_on_outlined, const Color(0xFFC70000), null),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyBackground,
      bottomNavigationBar: _buildBottomNav(context), 
      body: SafeArea(
        child: Column(children: [
            _header(context),
            Expanded(child: FutureBuilder<List<SubmissionData>>(
                future: _fetchLiveSubmissions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final submissions = snapshot.data ?? [];
                  return Column(children: [
                      _pill(),
                      Expanded(child: ListView.builder(itemCount: submissions.length, itemBuilder: (context, index) => _submissionListTile(context, submissions[index]))),
                  ]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color bg, Color textColor) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textColor)));

  Widget _submissionRow(String label, String status, IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(onTap: onTap, child: Row(children: [
      Text(label, style: const TextStyle(fontSize: 14.0)),
      const Spacer(),
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 4),
      Text(status, style: TextStyle(fontSize: 14.0, color: color, fontWeight: FontWeight.w500, decoration: onTap != null ? TextDecoration.underline : null)),
    ]));
  }
}