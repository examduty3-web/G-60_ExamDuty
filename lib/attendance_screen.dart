import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Location
import 'package:image_picker/image_picker.dart'; // Camera
import 'package:firebase_storage/firebase_storage.dart'; // Storage
import 'package:cloud_firestore/cloud_firestore.dart'; // Database
import 'package:firebase_auth/firebase_auth.dart'; // Auth UID

import 'exam_formalities.dart';
import 'login_screen.dart'; // to navigate user to login if needed

class AttendanceSelfieScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  // 🚨 ADDED: New required parameter
  final String userRole;

  const AttendanceSelfieScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole, // 🚨 ADDED
  });

  @override
  State<AttendanceSelfieScreen> createState() => _AttendanceSelfieScreenState();
}

class _AttendanceSelfieScreenState extends State<AttendanceSelfieScreen> {
  static const Color blueLeft = Color(0x9F1E2CF0);
  static const Color purpleRight = Color(0x946C0AF4);
  static const Color iconColor = Color(0xFF5335EA); // Used for primary colors

  String _statusMessage = 'Awaiting Attendance...';
  bool _isLoading = false;
  File? _selfieFile;
  Position? _currentPosition;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // For production: check location and camera permissions and request if needed.
    _statusMessage = 'Ready to capture attendance.';
    setState(() {});
  }

  /// Returns the current authenticated Firebase user, or null.
  User? _firebaseUser() => FirebaseAuth.instance.currentUser;

  Future<void> _captureAndSubmitAttendance() async {
    // Must be authenticated with Firebase — do not rely solely on widget.userEmail.
    final user = _firebaseUser();
    if (user == null) {
      // Not signed in — show a friendly UI (do not proceed).
      setState(() {
        _statusMessage = 'Error: Must be logged in to submit attendance.';
      });
      // Optionally show a dialog with a direct action to login:
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Capturing location and preparing upload...';
    });

    try {
      // --- 1) Get location ---
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // --- 2) Take selfie ---
      final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) {
        setState(() {
          _statusMessage = 'Capture cancelled.';
          _isLoading = false;
        });
        return;
      }

      _selfieFile = File(picked.path);

      // --- 3) Upload to Firebase Storage ---
      final String filePath =
          'uploads/${user.uid}/selfies/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref(filePath);

      // If running on platforms where putFile works:
      await storageRef.putFile(_selfieFile!);
      final String downloadUrl = await storageRef.getDownloadURL();

      // --- 4) Save record to Firestore ---
      await FirebaseFirestore.instance.collection('exam_duties').add({
        'userId': user.uid,
        'email': user.email ?? widget.userEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Attendance Submitted',
        'attendance': {
          'selfieUrl': downloadUrl,
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'accuracy': _currentPosition!.accuracy,
        },
        // Optional handy fields:
        'submittedBy': widget.userName,
        'userRole': widget.userRole, // 🚨 ADDED ROLE TO FIRESTORE SUBMISSION
      });

      setState(() {
        _statusMessage =
            'Attendance submitted successfully! Location: ${_currentPosition!.latitude.toStringAsFixed(3)}, ${_currentPosition!.longitude.toStringAsFixed(3)}';
      });
    } catch (e, st) {
      // Better error message for debugging
      setState(() {
        _statusMessage = 'Submission Failed: ${e.toString()}';
      });
      debugPrint('Attendance submission error: $e\n$st');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login required'),
        content: const Text(
            'You must be signed in with your BITS account to submit attendance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to Login — replace the current stack to avoid back navigation issues
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Go to Login'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = _firebaseUser();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top header
            Stack(
              children: [
                Container(width: double.infinity, height: 110, color: const Color(0xFF5335EA)),
                Padding(
                  padding: const EdgeInsets.only(top: 32, left: 9, right: 18),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).pushReplacement(
                          // 🚨 UPDATED: Pass userRole back to ExamFormalitiesScreen
                          MaterialPageRoute(
                            builder: (context) => ExamFormalitiesScreen(
                              userName: widget.userName, 
                              userEmail: widget.userEmail,
                              userRole: widget.userRole, // 🚨 PASSED ROLE
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text("ExamDuty+", style: TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 3))]),
                        child: Center(
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: const BoxDecoration(color: Color(0xFF5335EA), shape: BoxShape.circle),
                            child: const Icon(Icons.school_rounded, color: Colors.white, size: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Subject card (unchanged)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [blueLeft, purpleRight])),
                padding: const EdgeInsets.fromLTRB(17, 15, 17, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(children: [Text("Name of the Subject", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.6)), Spacer()]),
                    SizedBox(height: 7),
                    Row(children: [Icon(Icons.folder_copy_outlined, color: Colors.white, size: 17), SizedBox(width: 8), Text("Course Code", style: TextStyle(color: Colors.white, fontSize: 13.2))]),
                    SizedBox(height: 7),
                    Row(children: [Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16), SizedBox(width: 7), Text("Date", style: TextStyle(color: Colors.white, fontSize: 13.2)), Spacer(), Icon(Icons.access_time_rounded, color: Colors.white70, size: 16), SizedBox(width: 5), Text("Time", style: TextStyle(color: Colors.white, fontSize: 13.2))]),
                  ],
                ),
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFBEBEC7), width: 1)),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text("Attendance Selfie", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            const Text("Capture a geo-tagged selfie to mark your attendance for exam duty", style: TextStyle(fontSize: 13.2, color: Colors.black54)),
                            const SizedBox(height: 13),

                            // Photo / action area
                            Center(
                              child: Container(
                                width: 168,
                                height: 116,
                                decoration: BoxDecoration(color: const Color(0xFFF6F6FB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFD3D3DE), width: 1.4)),
                                child: firebaseUser == null
                                    ? _buildNotLoggedInTile()
                                    : (_selfieFile != null
                                        ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(_selfieFile!, fit: BoxFit.cover, width: 168, height: 116))
                                        : InkWell(
                                            onTap: _isLoading ? null : _captureAndSubmitAttendance,
                                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                              Icon(Icons.camera_alt_rounded, size: 38, color: Color(0xFFB0B2BC)),
                                              SizedBox(height: 8),
                                              Text("Take a selfie", style: TextStyle(fontSize: 15, color: Color(0xFF80819C))),
                                            ]),
                                          )),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Status message
                            Center(
                              child: Text(_statusMessage,
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: _statusMessage.toLowerCase().contains('success') ? Colors.green : Colors.black87)),
                            ),
                            const SizedBox(height: 14),

                            // Submit button (disabled if not logged in)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: (firebaseUser == null || _isLoading) ? null : _captureAndSubmitAttendance,
                                icon: _isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.check_circle),
                                label: Text(_isLoading ? 'Processing...' : 'Submit Attendance'),
                                style: ElevatedButton.styleFrom(backgroundColor: iconColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                              ),
                            ),

                            const SizedBox(height: 12),
                            // Small signed-in info (if available)
                            if (firebaseUser != null)
                              Center(child: Text('Signed in as: ${firebaseUser.email ?? widget.userEmail} (Role: ${widget.userRole})', style: const TextStyle(color: Colors.black54))),
                            if (firebaseUser == null)
                              Center(child: Text('Not signed in. Using: ${widget.userEmail}', style: const TextStyle(color: Colors.black45))),
                            const SizedBox(height: 12),

                            // Tips container
                            Container(
                              decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFFA4C7EA), width: 1.0)),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Row(children: [Icon(Icons.tips_and_updates_rounded, color: Color(0xFF288AD6), size: 18), SizedBox(width: 6), Text("Tips for a good selfie:", style: TextStyle(color: Color(0xFF288AD6), fontWeight: FontWeight.bold, fontSize: 14.2))]),
                                  SizedBox(height: 8),
                                  Text("• Ensure good lighting and clear visibility", style: TextStyle(fontSize: 13.1)),
                                  Text("• Face the camera directly", style: TextStyle(fontSize: 13.1)),
                                  Text("• Remove sunglasses or masks if possible", style: TextStyle(fontSize: 13.1)),
                                  Text("• Location will be automatically captured", style: TextStyle(fontSize: 13.1)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInTile() {
    return InkWell(
      onTap: () {
        // show login dialog
        _showLoginRequiredDialog();
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Icon(Icons.lock_outline, size: 34, color: Color(0xFFB0B2BC)),
        SizedBox(height: 8),
        Text('Take a selfie', style: TextStyle(fontSize: 15, color: Color(0xFF80819C))),
        SizedBox(height: 6),
        Text('Error: Must be logged in.', style: TextStyle(fontSize: 12, color: Colors.red)),
      ]),
    );
  }
}