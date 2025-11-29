import 'dart:io';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart'; // Location

import 'package:image_picker/image_picker.dart'; // Camera

import 'package:firebase_storage/firebase_storage.dart'; // Storage

import 'package:cloud_firestore/cloud_firestore.dart'; // Database

import 'package:firebase_auth/firebase_auth.dart'; // Auth UID



import 'exam_formalities.dart';

import 'login_screen.dart'; // used if user needs to be redirected to login



class AttendanceSelfieScreen extends StatefulWidget {

final String userName;

final String userEmail;



const AttendanceSelfieScreen({

super.key,

required this.userName,

required this.userEmail,

});



@override

State<AttendanceSelfieScreen> createState() => _AttendanceSelfieScreenState();

}



class _AttendanceSelfieScreenState extends State<AttendanceSelfieScreen> {

static const Color blueLeft = Color(0x9F1E2CF0);

static const Color purpleRight = Color(0x946C0AF4);

static const Color iconColor = Color(0xFF5335EA);



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

// For production: request location & camera permission. Simplified here.

setState(() {

_statusMessage = 'Ready to capture attendance.';

});

}



User? _firebaseUser() => FirebaseAuth.instance.currentUser;



Future<void> _captureAndSubmitAttendance() async {

final user = _firebaseUser();

if (user == null) {

setState(() {

_statusMessage = 'Error: Must be logged in to submit attendance.';

});

_showLoginRequiredDialog();

return;

}



setState(() {

_isLoading = true;

_statusMessage = 'Capturing location and preparing upload...';

});



try {

// 1) Get current location

_currentPosition = await Geolocator.getCurrentPosition(

desiredAccuracy: LocationAccuracy.high,

);



// 2) Capture selfie

final XFile? picked = await _picker.pickImage(source: ImageSource.camera);

if (picked == null) {

setState(() {

_statusMessage = 'Capture cancelled.';

_isLoading = false;

});

return;

}

_selfieFile = File(picked.path);



// 3) Upload to Firebase Storage

final String filePath =

'uploads/${user.uid}/selfies/${DateTime.now().millisecondsSinceEpoch}.jpg';

final Reference storageRef = FirebaseStorage.instance.ref(filePath);

await storageRef.putFile(_selfieFile!);

final String downloadUrl = await storageRef.getDownloadURL();



// 4) Save record to Firestore

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

'submittedBy': widget.userName,

});



setState(() {

_statusMessage =

'Attendance submitted successfully! Location: ${_currentPosition!.latitude.toStringAsFixed(3)}, ${_currentPosition!.longitude.toStringAsFixed(3)}';

});

} catch (e, st) {

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

TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),

ElevatedButton(

onPressed: () {

Navigator.of(context).pop();

// Replace stack and go to Login

Navigator.pushReplacement(

context,

MaterialPageRoute(builder: (_) => const LoginScreen()),

);

},

child: const Text('Go to Login'),

),

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

// Header

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

MaterialPageRoute(

builder: (context) => ExamFormalitiesScreen(

userName: widget.userName, userEmail: widget.userEmail),

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

// Subject header card (omitted here for brevity: you can reuse from your other file)

const SizedBox(height: 12),

Expanded(

child: SingleChildScrollView(

child: Padding(

padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 4),

child: Column(

crossAxisAlignment: CrossAxisAlignment.stretch,

children: [

// Attendance card

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



Center(

child: Text(_statusMessage, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _statusMessage.toLowerCase().contains('success') ? Colors.green : Colors.black87)),

),

const SizedBox(height: 14),



SizedBox(

width: double.infinity,

child: ElevatedButton.icon(

onPressed: (firebaseUser == null || _isLoading) ? null : _captureAndSubmitAttendance,

icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle),

label: Text(_isLoading ? 'Processing...' : 'Submit Attendance'),

style: ElevatedButton.styleFrom(backgroundColor: iconColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),

),

),

const SizedBox(height: 12),

if (firebaseUser != null)

Center(child: Text('Signed in as: ${firebaseUser.email ?? widget.userEmail}', style: const TextStyle(color: Colors.black54))),

if (firebaseUser == null) Center(child: Text('Not signed in. Using: ${widget.userEmail}', style: const TextStyle(color: Colors.black45))),

const SizedBox(height: 12),



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

onTap: _showLoginRequiredDialog,

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