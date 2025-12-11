import 'package:cloud_firestore/cloud_firestore.dart';

class HonorariumModel {
  // User Identification
  final String userId;
  final String userName;
  final String userEmail;
  final String userRole;
  
  // Overall Admin Tracking Fields (Summary View)
  final String? overallApprovalStatus; // New field for the total status (Approved/Rejected/Pending)
  final double? allocatedAmount; // New field for the TOTAL allocated amount (Travel + Stay)
  final Timestamp? submissionDate; // Changed to nullable Timestamp for safer handling

  // Travel Details and Status
  final String? travelDetails;
  final String? travelDate; // New field required by the summary card
  final String? travelStatus; // New field for Travel approval status
  final double? travelAmount; // New field for Allocated Travel Amount

  // Stay/Accommodation Details and Status
  final String? stayDetails;
  final String? stayDate; // New field required by the summary card
  final String? stayStatus; // New field for Stay approval status
  final double? stayAmount; // New field for Allocated Stay Amount
  
  HonorariumModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    this.travelDetails,
    this.stayDetails,
    this.overallApprovalStatus,
    this.allocatedAmount,
    this.submissionDate,
    this.travelDate,
    this.travelStatus,
    this.travelAmount,
    this.stayDate,
    this.stayStatus,
    this.stayAmount,
  });

  // Factory constructor to create a model instance from Firestore document data
  factory HonorariumModel.fromFirestore(Map<String, dynamic> data) {
    // Helper function to safely parse Firestore Timestamp or handle null
    DateTime parseTimestamp(dynamic ts) {
      if (ts is Timestamp) return ts.toDate();
      // Handle the case where the timestamp might be null or missing
      return DateTime.now(); 
    }

    return HonorariumModel(
      userId: data['userId'] as String? ?? 'N/A',
      userName: data['userName'] as String? ?? 'N/A',
      userEmail: data['userEmail'] as String? ?? 'N/A',
      userRole: data['userRole'] as String? ?? 'N/A',

      // Overall Fields (Read by the summary card)
      overallApprovalStatus: data['overallApprovalStatus'] as String? ?? 'Pending',
      allocatedAmount: (data['allocatedAmount'] as num?)?.toDouble() ?? 0.0,
      submissionDate: data['submissionDate'] as Timestamp?, // Keep as Timestamp for the raw data

      // Travel Fields (Required by the review dialog and summary card)
      travelDetails: data['travelDetails'] as String? ?? 'N/A',
      travelDate: data['travelDate'] as String?,
      travelStatus: data['travelStatus'] as String? ?? 'Pending',
      travelAmount: (data['travelAmount'] as num?)?.toDouble() ?? 0.0,

      // Stay Fields (Required by the review dialog and summary card)
      stayDetails: data['stayDetails'] as String? ?? 'N/A',
      stayDate: data['stayDate'] as String?,
      stayStatus: data['stayStatus'] as String? ?? 'Pending',
      stayAmount: (data['stayAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}