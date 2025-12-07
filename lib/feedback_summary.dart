// feedback_summary.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'feedback_model.dart'; // Ensure this file exists
import 'admin_dashboard_screen.dart';

// Reference to the Firestore collection where feedback is stored
final CollectionReference feedbackCollection = 
    FirebaseFirestore.instance.collection('examFeedbacks');

class FeedbackSummaryScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const FeedbackSummaryScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  // Helper method to build a dynamic feedback card based on the model
  Widget _buildFeedbackCard(FeedbackModel feedback) {
    // Determine the icon and color based on the overall rating
    IconData icon;
    Color iconColor;
    Color containerColor;

    // Logic for color/icon based on rating
    if (feedback.overallRating >= 4) { 
        icon = Icons.thumb_up_alt_rounded;
        iconColor = const Color(0xFF28A745); // Green (Good/Excellent)
        containerColor = const Color(0xFFE6F7EA);
    } else if (feedback.overallRating <= 2) {
        icon = Icons.thumb_down_alt_rounded;
        iconColor = Colors.red; // Red (Poor)
        containerColor = Colors.red.shade50;
    } else {
        icon = Icons.thumbs_up_down_rounded;
        iconColor = Colors.orange; // Orange (Average)
        containerColor = Colors.orange.shade50;
    }

    // Solution for showing all questions and ensuring display is accurate
    String allFeedbackText = 
        // Required Questions (Q1 through Q6)
        "Q1 (Power Supply): ${feedback.q1PowerSupply}\n"
        "Q2 (Power Backup): ${feedback.q2PowerBackup}\n"
        "Q3 (Connectivity): ${feedback.q3Connectivity}\n"
        "Q4 (Staff Support): ${feedback.q4StaffCooperation}\n"
        "Q5 (Invigilator Count): ${feedback.q5InvigilatorCount}\n"
        "Q6 (Travel Ease): ${feedback.q6TravelEase}\n"
        
        // Optional Fields (Suggestions and Issues)
        "${feedback.suggestions.isNotEmpty ? '\nSuggestions: ${feedback.suggestions}\n' : ''}"
        "${feedback.issues.isNotEmpty ? 'Issues: ${feedback.issues}\n' : ''}";


    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
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
            // top row (Icon, User/Email, Rating)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.userName, // DYNAMIC NAME
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feedback.userEmail, // DYNAMIC EMAIL
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.star,
                  color: Color(0xFFFFC107),
                  size: 18,
                ),
                const SizedBox(width: 2),
                // 🚨 FIX: This ensures the rating number shown is the actual number from Firestore.
                Text(
                  feedback.overallRating.toString(), // DYNAMIC RATING (e.g., "5")
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Combined feedback text - All fields included
            Text(
              allFeedbackText,
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E5FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    // 🚨 FIX: Display the actual overall rating in the bottom tag
                    "Overall Rating: ${feedback.overallRating}/5", 
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF5135EA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.black45,
                ),
                const SizedBox(width: 5),
                Text(
                  DateFormat('MMM d, h:mm a').format(feedback.timestamp.toLocal()), // DYNAMIC DATE
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Your existing helper widgets (omitted for brevity)
  Widget _buildBottomNav(BuildContext context) {
    // ... (Your existing _buildBottomNav implementation)
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
          // MY PROFILE (inactive)
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

  Widget _feedbackPill() {
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
          "Feedback Summary",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // STREAM BUILDER FOR REAL-TIME DATA
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER (omitted for brevity)
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
            
            _feedbackPill(),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: feedbackCollection.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  // Handle loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // Handle error state
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading feedback: ${snapshot.error}'));
                  }

                  // Handle no data state
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text("No feedback has been submitted yet.", style: TextStyle(fontSize: 16, color: Colors.black54)),
                      ),
                    );
                  }

                  // Convert documents to FeedbackModel list
                  final List<FeedbackModel> feedbackList = snapshot.data!.docs.map((doc) {
                    return FeedbackModel.fromFirestore(doc.data() as Map<String, dynamic>);
                  }).toList();

                  // Display the list of feedback cards
                  return ListView.builder(
                    itemCount: feedbackList.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      return _buildFeedbackCard(feedbackList[index]);
                    },
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