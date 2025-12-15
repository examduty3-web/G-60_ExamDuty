// travel_stay.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// 🚨 NEW IMPORTS FOR FIREBASE AND DATA
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'honorarium_model.dart';
import 'honorarium_status.dart'; // Navigation target for status screen

// 🚨 ADD IMPORTS FOR NAVIGATION TARGETS
import 'exam_formalities.dart'; 
import 'dashboard_screen.dart'; 
import 'bank_details.dart'; 

// 🚨 CRITICAL FIX: The collection reference must be 'travel_requests'
final CollectionReference travelRequestsCollection = 
    FirebaseFirestore.instance.collection('travel_requests');

class TravelStayScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole; 

  const TravelStayScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, 
  });

  @override
  State<TravelStayScreen> createState() => _TravelStayScreenState();
}

class _TravelStayScreenState extends State<TravelStayScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _travelRequired;
  String? _accommodationRequired; 

  final _preferredModeController = TextEditingController();
  final _departureCityController = TextEditingController();
  final _departureDateController = TextEditingController(); // This stores travel date
  final _accommodationTypeController = TextEditingController();
  final _checkInDateController = TextEditingController(); // This stores stay date
  final _contactInfoController = TextEditingController();
  final _specialReqController = TextEditingController();

  bool _isLoading = false;

  bool get _canSubmit {
    if (_isLoading) return false;
    // Perform basic validation before checking form key
    if (_contactInfoController.text.trim().length != 10) return false;

    if (_travelRequired == null) return false;
    if (_accommodationRequired == null) return false;
    
    return true;
  }

  Future<void> _pickDate({
    required TextEditingController controller,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      controller.text = "$day-$month-$year";
      setState(() {});
    }
  }
  
  // 🚨 CRITICAL FIX: Implement Firebase Submission Logic
  Future<void> _submitRequirements() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields correctly.")),
      );
      return;
    }
    if (!_canSubmit) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication error. Please log in again.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final String uid = user.uid;
    
    // --- 1. Prepare Data ---
    // Travel Details
    final String travelDetails = _travelRequired == 'yes' 
        ? "Mode: ${_preferredModeController.text}, City: ${_departureCityController.text}"
        : "None required/Self-arranged";
    final String travelDate = _travelRequired == 'yes' 
        ? _departureDateController.text : 'N/A';

    // Accommodation Details
    final String stayDetails = _accommodationRequired == 'yes' 
        ? "Type: ${_accommodationTypeController.text}"
        : "None required/Self-arranged";
    final String stayDate = _accommodationRequired == 'yes' 
        ? _checkInDateController.text : 'N/A';
    
    // --- 2. Build Submission Data (CRITICAL for Rule Check) ---
    final Map<String, dynamic> submissionData = {
      'userId': uid, // <--- CRITICAL: Ensures the rule check passes for Observer/SuperProctor
      'userName': widget.userName,
      'userEmail': widget.userEmail,
      'userRole': widget.userRole,
      'contactInfo': _contactInfoController.text.trim(),
      'specialRequirements': _specialReqController.text.trim(),

      // Travel fields
      'travelDetails': travelDetails,
      'travelDate': travelDate,
      'travelStatus': 'Pending', 
      'travelAmount': 0.0,

      // Stay fields
      'stayDetails': stayDetails,
      'stayDate': stayDate,
      'stayStatus': 'Pending',
      'stayAmount': 0.0,

      // Overall status fields (for summary/status screens)
      'overallApprovalStatus': 'Pending', 
      'allocatedAmount': 0.0,
      'submissionDate': FieldValue.serverTimestamp(),
    };

    // --- 3. Save to Firestore ---
    try {
      // 🚨 CRITICAL FIX: Using travelRequestsCollection which has the correct security rule setup
      // Use set() to overwrite/create the document using UID as the ID
      await travelRequestsCollection.doc(uid).set(submissionData); 
      
      if (!mounted) return;
      
      // --- 4. Show Success Dialog and Navigate ---
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Request Submitted"),
          content: const Text(
            "Your travel and accommodation requirements have been submitted for admin review. You can check the status now.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // Navigate to Honorarium Status Screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HonorariumStatusScreen(
                      userName: widget.userName,
                      userEmail: widget.userEmail,
                      userRole: widget.userRole,
                      userId: uid,
                    ),
                  ),
                );
              },
              child: const Text("Check Status"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // 🚨 Debugging the specific error
      print("Firestore Submission Error (Travel/Stay): $e"); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit requirements: [cloud_firestore/permission-denied] Missing or insufficient permissions. Please contact Admin.")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _preferredModeController.dispose();
    _departureCityController.dispose();
    _departureDateController.dispose();
    _accommodationTypeController.dispose();
    _checkInDateController.dispose();
    _contactInfoController.dispose();
    _specialReqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBarRounded(context),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
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
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ExamFormalitiesScreen(
                              userName: widget.userName,
                              userEmail: widget.userEmail,
                              userRole: widget.userRole, 
                            ),
                          ),
                        ),
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

            // SUBJECT CARD (Placeholder: assuming it exists)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Container(height: 120, color: const Color(0x9F1E2CF0).withOpacity(0.1)),
            ),
            
            // FORM CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17.0,
                    vertical: 5,
                  ),
                  child: Form(
                    key: _formKey,
                    onChanged: () => setState(() {}),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFBEBEC7),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 21, 18, 21),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Travel & Accommodation",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Specify your travel and accommodation requirements for exam duty",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Travel radio
                          const Text(
                            "Do you require travel arrangements?",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Yes, I need travel arrangements",
                              style: TextStyle(fontSize: 13.5),
                            ),
                            value: "yes",
                            groupValue: _travelRequired,
                            onChanged: (v) {
                              setState(() => _travelRequired = v);
                            },
                          ),
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "No, I will arrange my own travel",
                              style: TextStyle(fontSize: 13.5),
                            ),
                            value: "no",
                            groupValue: _travelRequired,
                            onChanged: (v) {
                              setState(() => _travelRequired = v);
                            },
                          ),
                          const SizedBox(height: 10),

                          // Travel details only if YES
                          if (_travelRequired == "yes")
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5EBFF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(14, 13, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "If Yes, please fill the below details",
                                    style: TextStyle(
                                      fontSize: 13.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _TextField(
                                    label: "Preferred mode of travel",
                                    hint: "e.g., flight",
                                    controller: _preferredModeController,
                                    isRequired: true,
                                  ),
                                  const SizedBox(height: 10),
                                  _TextField(
                                    label: "Departure City",
                                    hint: "e.g., Delhi",
                                    controller: _departureCityController,
                                    isRequired: true,
                                  ),
                                  const SizedBox(height: 10),
                                  _DateField(
                                    label: "Departure Date",
                                    controller: _departureDateController,
                                    onTap: () => _pickDate(
                                      controller: _departureDateController,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (_travelRequired == "yes")
                            const SizedBox(height: 18),

                          // Accommodation radio
                          const Text(
                            "Do you require accommodation?",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Yes, I need accommodation",
                              style: TextStyle(fontSize: 13.5),
                            ),
                            value: "yes",
                            groupValue: _accommodationRequired,
                            onChanged: (v) {
                              setState(() => _accommodationRequired = v);
                            },
                          ),
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "No, I have my own arrangements",
                              style: TextStyle(fontSize: 13.5),
                            ),
                            value: "no",
                            groupValue: _accommodationRequired,
                            onChanged: (v) {
                              setState(() => _accommodationRequired = v);
                            },
                          ),
                          const SizedBox(height: 10),

                          if (_accommodationRequired == "yes")
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5EBFF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(14, 13, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "If Yes, please fill the below details",
                                    style: TextStyle(
                                      fontSize: 13.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _TextField(
                                    label: "Accommodation Type",
                                    hint: "e.g., hotel/hostel",
                                    controller: _accommodationTypeController,
                                    isRequired: true,
                                  ),
                                  const SizedBox(height: 10),
                                  _DateField(
                                    label: "Check-in Date",
                                    controller: _checkInDateController,
                                    onTap: () => _pickDate(
                                      controller: _checkInDateController,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (_accommodationRequired == "yes")
                            const SizedBox(height: 18),

                          // Contact info with India flag +91 and 10-digit validation
                          const Text(
                            "Contact Information",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _contactInfoController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Required";
                              }
                              if (val.trim().length != 10) {
                                return "Enter a 10 digit mobile number";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF6F6FB),
                              hintText: "Enter your mobile number",
                              hintStyle: const TextStyle(
                                color: Color(0xFFB0B2BC),
                                fontSize: 13.3,
                              ),
                              prefixIcon: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // simple India flag using emoji
                                    const Text(
                                      "🇮🇳",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "+91",
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: const Color(0xFFCED0DD),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            "Special Requirements (Optional)",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _specialReqController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD6C4C4),
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7EFEF),
                              hintText:
                                  "Any dietary restrictions, accessibility needs, or any other special requirements...",
                              hintStyle: const TextStyle(
                                color: Color(0xFFB0A3A3),
                                fontSize: 13.3,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Center(
                            child: SizedBox(
                              width: 250,
                              height: 51,
                              child: ElevatedButton(
                                onPressed: (_canSubmit && !_isLoading)
                                    ? _submitRequirements
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5335EA),
                                  disabledBackgroundColor:
                                      const Color(0xFFB5B6C6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Submit Requirements",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
          _NavItem(
            icon: Icons.home_rounded, 
            label: "Home", 
            // 🚨 FIX: Navigate back to DashboardScreen with userRole
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => DashboardScreen(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                    userRole: widget.userRole, // 🚨 PASSING ROLE
                  ),
                ),
              );
            },
          ),
          _NavItem(icon: Icons.account_balance_rounded, label: "Bank Details", onTap: () {
             Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BankDetailsScreen(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                    userRole: widget.userRole,
                  ),
                ),
              );
          }),
          _NavItem(icon: Icons.account_balance_wallet_rounded, label: "Honorarium Status", onTap: () {
             Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HonorariumStatusScreen(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                    userRole: widget.userRole,
                    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                  ),
                ),
              );
          }),
          _NavItem(icon: Icons.person_rounded, label: "My Profile", onTap: () {
            // 💡 TODO: Navigate to ProfileScreen
          }),
        ],
      ),
    );
  }
}

// Replicating helper classes needed by the main widget
class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isRequired;
  final TextInputType? keyboardType;

  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.isRequired,
    // ignore: unused_element_parameter
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (val) {
            if (!isRequired) return null;
            if (val == null || val.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF6F6FB),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFB0B2BC),
              fontSize: 13.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
          onTap: onTap,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF6F6FB),
            hintText: "dd-mm-yyyy",
            hintStyle: const TextStyle(
              color: Color(0xFFB0B2BC),
              fontSize: 13.3,
            ),
            suffixIcon: const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: Color(0xFF777899),
            ),
          ),
        ),
      ],
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