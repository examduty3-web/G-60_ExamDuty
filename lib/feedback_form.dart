// feedback_form.dart
import 'package:flutter/material.dart';
// 🚨 NEW IMPORTS for Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feedback_model.dart'; // Ensure this file exists and contains the FeedbackModel

// 🚨 FIRESTORE COLLECTION REFERENCE
// Use a constant reference to your 'examFeedbacks' collection
final CollectionReference feedbackCollection = 
    FirebaseFirestore.instance.collection('examFeedbacks');

class FeedbackFormScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const FeedbackFormScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _q1Controller = TextEditingController();
  final _q2Controller = TextEditingController();
  final _q3Controller = TextEditingController();
  final _q4Controller = TextEditingController();
  final _q5Controller = TextEditingController();
  final _q6Controller = TextEditingController();
  final _suggestionsController = TextEditingController();
  final _issuesController = TextEditingController();

  int _overallRating = 0; // 1–5 stars

  bool _isLoading = false;

  // 🚨 UPDATED: Firestore Submission Logic
  Future<void> _submitFeedback() async {
    // 1. Validation Checks
    if (!_formKey.currentState!.validate()) return;
    if (_overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an overall exam duty rating."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Map form data to the FeedbackModel
    final newFeedback = FeedbackModel(
      userName: widget.userName,
      userEmail: widget.userEmail,
      userRole: widget.userRole,
      overallRating: _overallRating,
      q1PowerSupply: _q1Controller.text.trim(),
      q2PowerBackup: _q2Controller.text.trim(),
      q3Connectivity: _q3Controller.text.trim(),
      q4StaffCooperation: _q4Controller.text.trim(),
      q5InvigilatorCount: _q5Controller.text.trim(),
      q6TravelEase: _q6Controller.text.trim(),
      suggestions: _suggestionsController.text.trim(),
      issues: _issuesController.text.trim(),
      timestamp: DateTime.now(),
    );

    try {
      // 3. Save data to Firestore
      await feedbackCollection.add(newFeedback.toFirestore());

      if (!mounted) return;

      // 4. Show success dialog and navigate
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Success"),
          content:
              const Text("Your feedback has been submitted successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to the previous page
              },
              child: const Text("Okay"),
            ),
          ],
        ),
      );
      
      // Optional: Reset form fields after successful submission
      _q1Controller.clear();
      _q2Controller.clear();
      _q3Controller.clear();
      _q4Controller.clear();
      _q5Controller.clear();
      _q6Controller.clear();
      _suggestionsController.clear();
      _issuesController.clear();
      setState(() {
        _overallRating = 0;
      });

    } catch (e) {
      // 5. Handle submission error
      if (!mounted) return;
      print('Firebase Submission Error: $e'); // Log error for debugging
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submission failed: Please check your network or try again."),
        ),
      );
    } finally {
      // 6. Reset loading state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _q1Controller.dispose();
    _q2Controller.dispose();
    _q3Controller.dispose();
    _q4Controller.dispose();
    _q5Controller.dispose();
    _q6Controller.dispose();
    _suggestionsController.dispose();
    _issuesController.dispose();
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

            // SUBJECT CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x9F1E2CF0),
                      Color(0x946C0AF4),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(17, 15, 17, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Text(
                          "Name of the Subject",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.6,
                          ),
                        ),
                        Spacer(),
                        _ExamTypeChip(),
                      ],
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(Icons.folder_copy_outlined,
                            color: Colors.white, size: 17),
                        SizedBox(width: 8),
                        Text(
                          "Course Code",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 7),
                        Text(
                          "Date",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.2,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.access_time_rounded,
                            color: Colors.white70, size: 16),
                        SizedBox(width: 5),
                        Text(
                          "Time",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // FORM
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17.0,
                    vertical: 5,
                  ),
                  child: Form(
                    key: _formKey,
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
                            "Exam Duty Feedback",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Share your experience to help us improve the exam duty process",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // REQUIRED QUESTIONS
                          _QuestionField(
                            question:
                                "Was the power supply (electricity) consistent throughout the exam session?",
                            controller: _q1Controller,
                            isRequired: true,
                          ),
                          const SizedBox(height: 14),

                          _QuestionField(
                            question:
                                "If there was a power cut, was the backup (generator/UPS) activated promptly and maintained reliably?",
                            controller: _q2Controller,
                            isRequired: true,
                          ),
                          const SizedBox(height: 14),

                          _QuestionField(
                            question:
                                "Was the internet/network connectivity (where required) stable and sufficiently fast?",
                            controller: _q3Controller,
                            isRequired: true,
                          ),
                          const SizedBox(height: 14),

                          _QuestionField(
                            question:
                                "Was the cooperation and support from the examination center staff satisfactory?",
                            controller: _q4Controller,
                            isRequired: true,
                          ),
                          const SizedBox(height: 14),

                          _QuestionField(
                            question:
                                "Was the number of invigilators assigned to your room/area sufficient for effective supervision?",
                            controller: _q5Controller,
                            isRequired: true,
                          ),
                          const SizedBox(height: 14),

                          _QuestionField(
                            question:
                                "How easy was it to reach the exam center using your preferred mode of transport (e.g., public or private)?",
                            controller: _q6Controller,
                            isRequired: true,
                          ),
                          const SizedBox(height: 14),

                          // OPTIONAL
                          _QuestionField(
                            question: "Suggestions for Improvement",
                            controller: _suggestionsController,
                            isRequired: false,
                          ),
                          const SizedBox(height: 14),

                          _QuestionField(
                            question: "Issues Encountered (If any)",
                            controller: _issuesController,
                            isRequired: false,
                          ),
                          const SizedBox(height: 18),

                          // OVERALL RATING
                          const Text(
                            "Overall Exam Duty Rating",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(5, (index) {
                              final starIndex = index + 1;
                              final isFilled = _overallRating >= starIndex;
                              return IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _overallRating = starIndex;
                                  });
                                },
                                icon: Icon(
                                  Icons.star,
                                  size: 30,
                                  color: isFilled
                                      ? const Color(0xFFFFC107)
                                      : const Color(0xFFE0E0E0),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 22),

                          Center(
                            child: SizedBox(
                              width: 250,
                              height: 51,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : () => _submitFeedback(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5335EA),
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
                                        "Submit Feedback",
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
        children: const [
          _NavItem(icon: Icons.home_rounded, label: "Home"),
          _NavItem(icon: Icons.account_balance_rounded, label: "Bank Details"),
          _NavItem(
              icon: Icons.account_balance_wallet_rounded,
              label: "Honorarium Status"),
          _NavItem(icon: Icons.person_rounded, label: "My Profile"),
        ],
      ),
    );
  }
}

class _QuestionField extends StatelessWidget {
  final String question;
  final TextEditingController controller;
  final bool isRequired;

  const _QuestionField({
    required this.question,
    required this.controller,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 2,
          validator: (val) {
            if (!isRequired) return null;
            if (val == null || val.trim().isEmpty) {
              return "Please type your answer";
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
            hintText: "Please type your answer",
            hintStyle: const TextStyle(
              color: Color(0xFFB0B2BC),
              fontSize: 13.5,
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

  const _NavItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _ExamTypeChip extends StatelessWidget {
  const _ExamTypeChip();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}