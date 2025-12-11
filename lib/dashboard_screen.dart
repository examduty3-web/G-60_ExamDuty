import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'exam_formalities.dart';
import 'bank_details.dart';
import 'honorarium_status.dart';
// Note: Ensure placeholder files for HonorariumStatusScreen and MyProfileScreen 
// are created and accept the three required parameters.

// 🛠️ CORRECTED HELPER FUNCTION
String _capitalize(String s) {
  if (s.isEmpty) return s;
  // Capitalize the first letter and make the rest lowercase
  s = s.toLowerCase();
  return s[0].toUpperCase() + s.substring(1);
}

class DashboardScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole; 

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, 
  });

  void _showLogoutDialog(BuildContext context) {
    // ... (Logout logic remains the same)
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
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Color(0xFF5335EA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedUserName = _capitalize(userName); 
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
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
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: () => _showLogoutDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                    padding: const EdgeInsets.symmetric(
                      vertical: 17,
                      horizontal: 14,
                    ),
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
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 17),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedUserName, 
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
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
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
          // Your Exam Duties
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.5, vertical: 0),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Exam Duties",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Select an exam duty to manage submissions",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                _RoleButtonSmall(userRole: userRole), 
              ],
            ),
          ),
          _buildEvolutionOfDesignFinal(context),
          const Spacer(),
          _buildInstituteLogo(),
        ],
      ),
      bottomNavigationBar: _buildBottomBarRounded(context),
    );
  }

  Widget _buildEvolutionOfDesignFinal(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
          ),
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Name of the Subject",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0A1),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.currency_rupee,
                          color: Color(0xFFF9A825),
                          size: 16,
                        ),
                        SizedBox(width: 2),
                        Text(
                          "Pending",
                          style: TextStyle(
                            color: Color(0xFFF9A825),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 3),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExamFormalitiesScreen(
                            userName: userName,
                            userEmail: userEmail,
                            userRole: userRole, 
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black38,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 17,
                    color: Color(0xFF7B78AA),
                  ),
                  SizedBox(width: 7),
                  Text(
                    "15 Nov 2025",
                    style: TextStyle(
                      color: Color(0xFF7B78AA),
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 17,
                    color: Color(0xFF7B78AA),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Forenoon",
                    style: TextStyle(
                      color: Color(0xFF7B78AA),
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.location_on_outlined,
                    size: 19,
                    color: Color(0xFF7B78AA),
                  ),
                  SizedBox(width: 7),
                  Text(
                    "Lucknow",
                    style: TextStyle(
                      color: Color(0xFF7B78AA),
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.description_outlined,
                    size: 17,
                    color: Color(0xFF7B78AA),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Mid-Semester",
                    style: TextStyle(
                      color: Color(0xFF7B78AA),
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 19,
                    color: Color(0xFF7B78AA),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    "Progress",
                    style: TextStyle(
                      color: Color(0xFF7B78AA),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: 0.0,
                      backgroundColor: const Color(0xFFDCDFFB),
                      color: const Color(0xFF7B78AA),
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    "0%",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstituteLogo() {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: Image.asset(
            "assets/bits_pilani.png",
            height: 55,
            fit: BoxFit.contain,
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
              // already here
            },
          ),
          _NavItem(
            icon: Icons.account_balance_rounded,
            label: "Bank Details",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BankDetailsScreen(
                    userName: userName,
                    userEmail: userEmail,
                    userRole: userRole, 
                  ),
                ),
              );
            },
          ),
          _NavItem(
  icon: Icons.account_balance_wallet_rounded,
  label: "Honorarium Status",
  onTap: () {
    // 🚨 OLD: debugPrint("Honorarium tapped");
    
    // 🚨 NEW: Navigation code must be implemented here:
    // 1. Get the current user's UID (Required for fetching status)
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HonorariumStatusScreen(
          userName: userName,   // assuming these are class/widget properties
          userEmail: userEmail, // assuming these are class/widget properties
          userRole: userRole,   // assuming these are class/widget properties
          
          // 🚨 CRITICAL FIX: Pass the current user's UID
          userId: currentUserId, 
        ),
      ),
    );
  },
),
          _NavItem(
            icon: Icons.person_rounded,
            label: "My Profile",
            onTap: () {
              // NOTE: If MyProfileScreen exists, update navigation here.
              debugPrint("Profile tapped");
            },
          ),
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

class _RoleButtonSmall extends StatelessWidget {
  // 🚨 NEW: Requires the userRole string
  final String userRole; 

  const _RoleButtonSmall({required this.userRole});

  @override
  Widget build(BuildContext context) {
    // 🚨 FIX: ROBUST ROLE FORMATTING LOGIC
    // 1. Sanitize the string by replacing common separators (like underscores) with spaces,
    // and ensuring it's lowercased before capitalization.
    String cleanRole = userRole
        .replaceAll('_', ' ')                   // Handle snake_case like super_proctor
        .replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ') // Handle camelCase like SuperProctor
        .trim();

    // 2. Capitalize each word, resolving issues like '$1' and lowercase roles.
    String displayRole = cleanRole
        .split(' ')
        .map((word) => _capitalize(word))
        .join(' ');
        
    // Handle the case where Firestore returned an empty/misspelled role.
    if (displayRole.isEmpty) {
        displayRole = 'Guest'; 
    }
    
    // Fallback check to correct "Guest" if the user should be Admin/SuperProctor 
    // (This relies on correct Firestore data)
    if (userRole.toLowerCase().contains('admin')) {
        displayRole = 'Admin';
    }

    return Container(
      margin: const EdgeInsets.only(left: 7, right: 6),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF694AF6),
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          minimumSize: const Size(8, 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: const BorderSide(
              color: Color(0xFFD9D5F8),
              width: 1,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(displayRole), // 🚨 DISPLAY THE DYNAMIC ROLE
      ),
    );
  }
}