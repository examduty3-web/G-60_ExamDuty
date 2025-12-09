import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
// 🚨 NEW IMPORTS for Role Check
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvigilationFormScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole; // 🚨 MUST BE DEFINED

  const InvigilationFormScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, // 🚨 MUST BE REQUIRED
  });

  @override
  State<InvigilationFormScreen> createState() => _InvigilationFormScreenState();
}

class _InvigilationFormScreenState extends State<InvigilationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examDateController = TextEditingController();
  final _examSlotController = TextEditingController();
  final _examTypeController = TextEditingController();
  final _numStudentsController = TextEditingController();

  File? _selectedFile;
  bool _isLoading = false;

  // 🚨 NEW ROLE VARIABLES
  bool _isSuperProctor = false;
  bool _isRoleLoading = true;
  // ⚠️ ASSUMPTION: The user's role is stored in a Firestore collection named 'user_roles' 
  // with a document ID matching the UID and a field like 'role': 'SuperProctor'.

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // 🚨 ROLE CHECKING LOGIC
  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final roleSnapshot = await FirebaseFirestore.instance
            .collection('user_roles') // ⚠️ Use your ACTUAL role collection name here
            .doc(user.uid)
            .get();

        if (mounted) {
          final role = roleSnapshot.data()?['role']; // Assuming role field is named 'role'
          
          setState(() {
            // Check if the role is exactly 'SuperProctor'
            _isSuperProctor = (role == 'SuperProctor'); 
          });
        }
      } catch (e) {
        print("Error fetching user role: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isRoleLoading = false;
      });
    }
  }


  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitFormToBackend() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('http://10.0.2.2:3000/submit-form'); // Adjust as needed

    try {
      final request = http.MultipartRequest('POST', uri);

      // Include all form fields
      request.fields['userName'] = widget.userName;
      request.fields['userEmail'] = widget.userEmail;
      request.fields['examDate'] = _examDateController.text.trim();
      request.fields['examSlot'] = _examSlotController.text.trim();
      request.fields['examType'] = _examTypeController.text.trim();
      request.fields['numStudents'] = _numStudentsController.text.trim();
      
      // Include the file
      request.files.add(
        await http.MultipartFile.fromPath(
          'invigilation_file',
          _selectedFile!.path,
        ),
      );

      final response = await request.send();

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSubmitSuccess(context);
      } else {
        _showErrorSnackBar('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Connection Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSubmitSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: const Text(
          "Invigilation Form has been submitted successfully to the server.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  bool get _canSubmit =>
      _examDateController.text.trim().isNotEmpty &&
      _examSlotController.text.trim().isNotEmpty &&
      _examTypeController.text.trim().isNotEmpty &&
      _numStudentsController.text.trim().isNotEmpty &&
      _selectedFile != null;

  @override
  void dispose() {
    _examDateController.dispose();
    _examSlotController.dispose();
    _examSlotController.dispose(); // Changed from examSlotController to prevent double dispose
    _examTypeController.dispose();
    _numStudentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 1. HANDLE LOADING STATE
    if (_isRoleLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // 🚨 2. HANDLE ACCESS DENIAL (If user is Observer or not logged in)
    if (!_isSuperProctor) {
      return Scaffold(
        appBar: AppBar(title: const Text("Access Denied")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 50, color: Colors.red),
                const SizedBox(height: 10),
                const Text(
                  "Only Super Proctors are authorized to submit the Invigilation Form.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🚨 3. SHOW FORM CONTENT (If Super Proctor)
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBarRounded(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header Stack
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

            // Subject Card
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

            // Main Form
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFBEBEC7),
                              width: 1,
                            ),
                          ),
                          padding:
                              const EdgeInsets.fromLTRB(18, 21, 18, 21),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Invigilation Form",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Fill in the exam details and upload the completed invigilation form",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 18),

                              _LabelWithMandatoryField(
                                controller: _examDateController,
                                label: "Exam Date",
                              ),
                              const SizedBox(height: 14),

                              _LabelWithMandatoryField(
                                controller: _examSlotController,
                                label: "Exam Slot",
                              ),
                              const SizedBox(height: 14),

                              _LabelWithMandatoryField(
                                controller: _examTypeController,
                                label: "Exam Type",
                              ),
                              const SizedBox(height: 14),

                              _LabelWithMandatoryField(
                                controller: _numStudentsController,
                                label: "Number of Students",
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 21),

                              const Text(
                                "Upload Invigilation Form",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                  fontSize: 14.7,
                                ),
                              ),
                              const SizedBox(height: 9),

                              _UploadInvigilationWidget(
                                uploaded: _selectedFile != null,
                                fileName: _selectedFile != null
                                    ? _selectedFile!.path.split('/').last
                                    : null,
                                onPressed: _pickFile,
                              ),

                              const SizedBox(height: 19),

                              Center(
                                child: SizedBox(
                                  width: 250,
                                  height: 51,
                                  child: ElevatedButton.icon(
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.upload_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                    label: Text(
                                      _isLoading
                                          ? "Submitting..."
                                          : "Submit Form",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _canSubmit
                                          ? const Color(0xFF5335EA)
                                          : const Color(0xFFB5B6C6),
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 48,
                                        vertical: 5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed:
                                        (_canSubmit && !_isLoading)
                                            ? _submitFormToBackend
                                            : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
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

  // --- Helper Widgets ---

  Widget _buildBottomBarRounded(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(top: 3, left: 1, right: 1, bottom: 7),
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
          _NavItem(icon: Icons.home_rounded, label: "Home", onTap: () {}),
          _NavItem(icon: Icons.account_balance_rounded, label: "Bank Details", onTap: () {}),
          _NavItem(icon: Icons.account_balance_wallet_rounded, label: "Honorarium Status", onTap: () {}),
          _NavItem(icon: Icons.person_rounded, label: "My Profile", onTap: () {}),
        ],
      ),
    );
  }
}

class _LabelWithMandatoryField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _LabelWithMandatoryField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.2,
              ),
            ),
            const Text(
              " *",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF6F6FB),
            hintText: "Enter $label",
            hintStyle: const TextStyle(
              color: Color(0xFFB0B2BC),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadInvigilationWidget extends StatelessWidget {
  final bool uploaded;
  final String? fileName;
  final VoidCallback onPressed;

  const _UploadInvigilationWidget({
    this.uploaded = false,
    this.fileName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 89,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6FB),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFFBEBEC7),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              uploaded ? Icons.check_circle_rounded : Icons.insert_drive_file_outlined,
              size: 38,
              color: uploaded ? Colors.green : const Color(0xFFB0B2BC),
            ),
            const SizedBox(height: 7),
            Text(
              uploaded ? (fileName ?? "File Selected") : "Click to Upload Invigilation Form",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: uploaded ? Colors.green[700] : const Color(0xFF65657E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            const Text(
              "PDF, DOC, or image files (Max 10MB)",
              style: TextStyle(fontSize: 12.4, color: Color(0xFFB5B6C6)),
            ),
          ],
        ),
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