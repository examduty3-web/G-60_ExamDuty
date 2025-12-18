import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for dynamic data
import 'login_screen.dart';
import 'exam_formalities.dart';
import 'bank_details.dart';
import 'honorarium_status.dart';

// 🛠️ YOUR ORIGINAL HELPER FUNCTION - RETAINED
String _capitalize(String s) {
  if (s.isEmpty) return s;
  s = s.toLowerCase();
  return s[0].toUpperCase() + s.substring(1);
}

class DashboardScreen extends StatefulWidget { // Converted to StatefulWidget for Refresh logic
  final String userName;
  final String userEmail;
  final String userRole; 

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, 
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 🚨 STATE FOR DYNAMIC DATA
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = _fetchDashboardStats();
  }

  // 🚨 PULL TO REFRESH LOGIC
  Future<void> _handleRefresh() async {
    setState(() {
      _dashboardData = _fetchDashboardStats();
    });
    await _dashboardData;
  }

  // 🚨 DYNAMIC CALCULATION LOGIC
  Future<Map<String, dynamic>> _fetchDashboardStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final firestore = FirebaseFirestore.instance;

    final results = await Future.wait([
      firestore.collection('exam_duties').where('userId', isEqualTo: uid).limit(1).get(),
      firestore.collection('examFeedbacks').where('userId', isEqualTo: uid).limit(1).get(),
      firestore.collection('exam_submissions').doc(uid).get(),
      firestore.collection('travel_requests').doc(uid).get(),
    ]);

    // Explicit casting to prevent "docs not defined" error
    final attendanceSnap = results[0] as QuerySnapshot;
    final feedbackSnap = results[1] as QuerySnapshot;
    final invigilationSnap = results[2] as DocumentSnapshot;
    final travelSnap = results[3] as DocumentSnapshot;

    bool hasAttendance = attendanceSnap.docs.isNotEmpty;
    bool hasFeedback = feedbackSnap.docs.isNotEmpty;
    bool hasInvigilation = invigilationSnap.exists;
    bool hasTravel = travelSnap.exists;

    double progressValue = 0.0;
    if (hasAttendance) progressValue += 0.25;
    if (hasFeedback) progressValue += 0.25;
    if (hasInvigilation) progressValue += 0.25;
    if (hasTravel) progressValue += 0.25;

    String hStatus = "Pending";
    if (hasTravel) {
      hStatus = travelSnap.get('overallApprovalStatus') ?? "Pending";
    }

    return {'progress': progressValue, 'status': hStatus};
  }

  // 🛠️ YOUR ORIGINAL LOGOUT DIALOG - RETAINED
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text(
          "Are you sure you want to logout?\nYou will be redirected to the login screen.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (!context.mounted) return;
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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

  @override
  Widget build(BuildContext context) {
    final String formattedUserName = _capitalize(widget.userName); 
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator( // 🚨 WRAPPED FOR PULL-TO-REFRESH
        onRefresh: _handleRefresh,
        color: const Color(0xFF5335EA),
        child: SingleChildScrollView( // 🚨 ENABLES SCROLLING
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(height: 210, width: double.infinity, color: const Color(0xFF5335EA)),
                  Column(
                    children: [
                      const SizedBox(height: 44),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Container(
                              width: 51, height: 51,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                              ),
                              child: Center(
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: const BoxDecoration(color: Color(0xFF5335EA), shape: BoxShape.circle),
                                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 21),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "ExamDuty+",
                              style: TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white, size: 26),
                              onPressed: () => _showLogoutDialog(context),
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
                          boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.13), blurRadius: 8, offset: const Offset(0, 5))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
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
                                  formattedUserName, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.5, color: Colors.white, fontFamily: "Poppins"),
                                ),
                                const SizedBox(height: 3),
                                Text(widget.userEmail, style: const TextStyle(fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.5),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your Exam Duties", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
                          SizedBox(height: 2),
                          Text("Select an exam duty to manage submissions", style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    _RoleButtonSmall(userRole: widget.userRole), 
                  ],
                ),
              ),
              
              // 🚨 DYNAMIC SECTION
              FutureBuilder<Map<String, dynamic>>(
                future: _dashboardData,
                builder: (context, snapshot) {
                  double progress = 0.0;
                  String status = "Pending";
                  if (snapshot.hasData) {
                    progress = snapshot.data!['progress'];
                    status = snapshot.data!['status'];
                  }
                  return _buildEvolutionOfDesignFinal(context, status, progress);
                },
              ),
              
              const SizedBox(height: 40),
              _buildInstituteLogo(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBarRounded(context),
    );
  }

  // 🛠️ YOUR ORIGINAL DESIGN - RETAINED
  Widget _buildEvolutionOfDesignFinal(BuildContext context, String status, double progress) {
    Color statusColor = status == "Approved" ? Colors.green : const Color(0xFFF9A825);
    Color statusBg = status == "Approved" ? Colors.green.withOpacity(0.15) : const Color(0xFFFFE0A1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Name of the Subject", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(19)),
                    child: Row(
                      children: [
                        Icon(Icons.currency_rupee, color: statusColor, size: 16),
                        const SizedBox(width: 2),
                        Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 3),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExamFormalitiesScreen(userName: widget.userName, userEmail: widget.userEmail, userRole: widget.userRole))),
                    child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              _buildInfoRow(Icons.calendar_today_outlined, "15 Nov 2025", Icons.schedule, "Forenoon"),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.location_on_outlined, "Lucknow", Icons.description_outlined, "Mid-Semester"),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.trending_up, size: 19, color: Color(0xFF7B78AA)),
                  const SizedBox(width: 7),
                  const Text("Progress", style: TextStyle(color: Color(0xFF7B78AA), fontSize: 15)),
                  const SizedBox(width: 10),
                  // 🚨 DYNAMIC PROGRESS BAR
                  Expanded(child: LinearProgressIndicator(minHeight: 7, value: progress, backgroundColor: const Color(0xFFDCDFFB), color: const Color(0xFF5335EA))),
                  const SizedBox(width: 7),
                  Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.black87, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, IconData icon2, String text2) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF7B78AA)),
        const SizedBox(width: 7),
        Text(text, style: const TextStyle(color: Color(0xFF7B78AA), fontSize: 15)),
        const Spacer(),
        Icon(icon2, size: 17, color: const Color(0xFF7B78AA)),
        const SizedBox(width: 5),
        Text(text2, style: const TextStyle(color: Color(0xFF7B78AA), fontSize: 15)),
      ],
    );
  }

  Widget _buildInstituteLogo() {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: Image.asset("assets/bits_pilani.png", height: 55, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildBottomBarRounded(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 3, left: 1, right: 1, bottom: 7),
      decoration: BoxDecoration(
        color: Colors.grey[200]?.withOpacity(0.95),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: "Home", onTap: () {}),
          _NavItem(icon: Icons.account_balance_rounded, label: "Bank Details", onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BankDetailsScreen(userName: widget.userName, userEmail: widget.userEmail, userRole: widget.userRole)))),
          _NavItem(icon: Icons.account_balance_wallet_rounded, label: "Honorarium Status", onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HonorariumStatusScreen(userName: widget.userName, userEmail: widget.userEmail, userRole: widget.userRole, userId: FirebaseAuth.instance.currentUser!.uid)))),
          _NavItem(icon: Icons.person_rounded, label: "My Profile", onTap: () {}),
        ],
      ),
    );
  }
}

// 🛠️ YOUR ORIGINAL NAV ITEM - RETAINED
class _NavItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: const Color(0xFF196BDE), size: 28), const SizedBox(height: 2), Text(label, style: const TextStyle(color: Color(0xFF196BDE), fontSize: 13, fontWeight: FontWeight.w500))]),
    );
  }
}

// 🛠️ YOUR ORIGINAL ROLE BUTTON - RETAINED
class _RoleButtonSmall extends StatelessWidget {
  final String userRole;
  const _RoleButtonSmall({required this.userRole});
  @override
  Widget build(BuildContext context) {
    String cleanRole = userRole.replaceAll('_', ' ').replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ').trim();
    String displayRole = cleanRole.split(' ').map((word) => _capitalize(word)).join(' ');
    if (displayRole.isEmpty) displayRole = 'Guest'; 
    if (userRole.toLowerCase().contains('admin')) displayRole = 'Admin';

    return Container(
      margin: const EdgeInsets.only(left: 7, right: 6),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, foregroundColor: const Color(0xFF694AF6), elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7), minimumSize: const Size(8, 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13), side: const BorderSide(color: Color(0xFFD9D5F8))),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        child: Text(displayRole),
      ),
    );
  }
}