// feedback_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String userName;
  final String userEmail;
  // 🚨 ADDED: Field for the user's role
  final String userRole; 
  
  final int overallRating;
  final String q1PowerSupply;
  final String q2PowerBackup;
  final String q3Connectivity;
  final String q4StaffCooperation;
  final String q5InvigilatorCount;
  final String q6TravelEase;
  final String suggestions;
  final String issues;
  final DateTime timestamp;

  FeedbackModel({
    required this.userName,
    required this.userEmail,
    required this.userRole, 
    
    required this.overallRating,
    required this.q1PowerSupply,
    required this.q2PowerBackup,
    required this.q3Connectivity,
    required this.q4StaffCooperation,
    required this.q5InvigilatorCount,
    required this.q6TravelEase,
    required this.suggestions,
    required this.issues,
    required this.timestamp,
  });

  // Convert Dart object to a Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'userName': userName,
      'userEmail': userEmail,
      'userRole': userRole, 
      'overallRating': overallRating,
      'q1PowerSupply': q1PowerSupply,
      'q2PowerBackup': q2PowerBackup,
      'q3Connectivity': q3Connectivity,
      'q4StaffCooperation': q4StaffCooperation,
      'q5InvigilatorCount': q5InvigilatorCount,
      'q6TravelEase': q6TravelEase,
      'suggestions': suggestions,
      'issues': issues,
      'timestamp': timestamp.toUtc(), // Use UTC for consistent storage
    };
  }

  // Factory constructor to create a model from Firestore data (used in summary)
  factory FeedbackModel.fromFirestore(Map<String, dynamic> data) {
    // Helper to safely convert Firestore Timestamp or DateTime
    DateTime parseTimestamp(dynamic ts) {
        if (ts is Timestamp) {
            return ts.toDate();
        } else if (ts is DateTime) {
            return ts;
        }
        return DateTime.now();
    }
    
    return FeedbackModel(
      userName: data['userName'] as String? ?? 'N/A',
      userEmail: data['userEmail'] as String? ?? 'N/A',
      // 🚨 ADDED: Retrieving the userRole from Firestore
      userRole: data['userRole'] as String? ?? 'N/A', 
      
      overallRating: data['overallRating'] as int? ?? 0,
      q1PowerSupply: data['q1PowerSupply'] as String? ?? '',
      q2PowerBackup: data['q2PowerBackup'] as String? ?? '',
      q3Connectivity: data['q3Connectivity'] as String? ?? '',
      q4StaffCooperation: data['q4StaffCooperation'] as String? ?? '',
      q5InvigilatorCount: data['q5InvigilatorCount'] as String? ?? '',
      q6TravelEase: data['q6TravelEase'] as String? ?? '',
      suggestions: data['suggestions'] as String? ?? '',
      issues: data['issues'] as String? ?? '',
      // FIX: Use the safe parser for timestamp handling
      timestamp: parseTimestamp(data['timestamp']), 
    );
  }
}