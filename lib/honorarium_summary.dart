import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'honorarium_model.dart';
import 'admin_dashboard_screen.dart';
import 'package:intl/intl.dart';

// --- COLOR PALETTE DEFINITION --- 
const Color primaryPurple = Color(0xFF5335EA);
const Color accentGreen = Color(0xFF54B478);
const Color lightGreyBackground = Color(0xFFF0F0F0); 
const Color darkGreyText = Color(0xFF65657E);
const Color statusPendingColor = Color(0xFFFF9800);

final CollectionReference honorariumCollection = 
    FirebaseFirestore.instance.collection('honorariumSubmissions');

class HonorariumSummaryScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const HonorariumSummaryScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<HonorariumSummaryScreen> createState() => _HonorariumSummaryScreenState();
}

class _HonorariumSummaryScreenState extends State<HonorariumSummaryScreen> {
  
  Future<List<HonorariumModel>> _fetchPendingSubmissions() async {
    final querySnapshot = await honorariumCollection
        .where('overallApprovalStatus', isEqualTo: 'Pending') // Use overall status for summary filter
        .get();
        
    return querySnapshot.docs.map((doc) => 
        HonorariumModel.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
  }

  // ---------------- ADMIN ACTION LOGIC ----------------

  // 🚨 FIX: Shows the decision dialog with refined dynamic amount input
  void _showApprovalDialog(BuildContext context, HonorariumModel model) {
    
    showDialog(
      context: context,
      builder: (ctx) {
        
        // --- Initial States (Managed locally by StatefulBuilder) ---
        // We use the current stored status/amount as initial values
        String selectedTravelStatus = model.travelStatus ?? 'Pending';
        TextEditingController travelAmountController = 
            TextEditingController(text: (model.travelAmount ?? 0.0).toStringAsFixed(2));

        String selectedStayStatus = model.stayStatus ?? 'Pending';
        TextEditingController stayAmountController = 
            TextEditingController(text: (model.stayAmount ?? 0.0).toStringAsFixed(2));
        // -----------------------------------------------------------

        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            
            bool isTravelApproved = selectedTravelStatus == 'Approved';
            bool isStayApproved = selectedStayStatus == 'Approved';

            return AlertDialog(
              title: Text("Review: ${model.userName} (${model.userRole})"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // === 1. TRAVEL DETAILS REVIEW ===
                    const Text("Travel Details Submitted:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(model.travelDetails ?? 'No travel details submitted.'), // Now shows submitted text
                    Text("Date: ${model.travelDate ?? 'N/A'}"),
                    const SizedBox(height: 10),

                    // Travel Status Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedTravelStatus,
                      decoration: const InputDecoration(labelText: 'Travel Approval Status'),
                      items: ['Pending', 'Approved', 'Rejected'].map((String status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() { 
                            selectedTravelStatus = newValue;
                            // If not approved, reset amount field visually
                            if (newValue != 'Approved') {
                              travelAmountController.text = '0.00'; 
                            }
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 10),
                    // Travel Amount Input (Enabled only if Approved)
                    TextField(
                      controller: travelAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Allocate Travel Amount (₹)",
                        prefixText: '₹ ',
                        enabled: isTravelApproved,
                        fillColor: isTravelApproved ? null : lightGreyBackground,
                        filled: !isTravelApproved,
                      ),
                      readOnly: !isTravelApproved, 
                    ),

                    const SizedBox(height: 25),

                    // === 2. STAY DETAILS REVIEW ===
                    const Text("Accommodation Details Submitted:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(model.stayDetails ?? 'No accommodation details submitted.'), // Now shows submitted text
                    Text("Date: ${model.stayDate ?? 'N/A'}"),
                    const SizedBox(height: 10),

                    // Stay Status Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedStayStatus,
                      decoration: const InputDecoration(labelText: 'Accommodation Approval Status'),
                      items: ['Pending', 'Approved', 'Rejected'].map((String status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() { 
                            selectedStayStatus = newValue;
                            // If not approved, reset amount field visually
                            if (newValue != 'Approved') {
                              stayAmountController.text = '0.00'; 
                            }
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 10),
                    // Stay Amount Input (Enabled only if Approved)
                    TextField(
                      controller: stayAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Allocate Accommodation Amount (₹)",
                        prefixText: '₹ ',
                        enabled: isStayApproved,
                        fillColor: isStayApproved ? null : lightGreyBackground,
                        filled: !isStayApproved,
                      ),
                      readOnly: !isStayApproved, 
                    ),

                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    // Submit both decisions to the Firestore update function
                    _updateApprovalStatus(
                      context,
                      model.userId, // Document ID
                      selectedTravelStatus,
                      double.tryParse(travelAmountController.text) ?? 0.0, // Parse current text
                      selectedStayStatus,
                      double.tryParse(stayAmountController.text) ?? 0.0, // Parse current text
                    );
                    Navigator.of(ctx).pop(); // Close dialog after submission starts
                  },
                  child: const Text("Submit Decisions"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🚨 FIX: Updated update function signature to handle both Travel and Stay amounts
  void _updateApprovalStatus(
    BuildContext context, 
    String docId, 
    String travelStatus, 
    double travelAmount,
    String stayStatus,
    double stayAmount,
  ) async {
    
    // Determine overall status based on the two items
    String overallStatus = 'Approved';
    if (travelStatus == 'Rejected' || stayStatus == 'Rejected') {
        overallStatus = 'Rejected';
    } else if (travelStatus == 'Pending' || stayStatus == 'Pending') {
        overallStatus = 'Pending';
    } else {
        // If both are Approved
        overallStatus = 'Approved';
    }

    try {
      await honorariumCollection.doc(docId).update({
        // Travel fields
        'travelStatus': travelStatus,
        'travelAmount': travelAmount,
        
        // Stay fields
        'stayStatus': stayStatus,
        'stayAmount': stayAmount,
        
        // Overall tracking
        'overallApprovalStatus': overallStatus,
        'allocatedAmount': travelAmount + stayAmount, // Sum of both amounts
        'reviewedBy': widget.userName,
        'reviewDate': FieldValue.serverTimestamp(),
      });

      // Refresh the list immediately
      setState(() {}); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review for $docId updated to $overallStatus.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e")),
      );
    }
  }


  // ---------------- UI BUILDERS ----------------

  // The summary card shows a compact view of all data
  Widget _buildUserSummaryCard(HonorariumModel model) {
    // Determine overall status for card display
    Color statusColor = model.overallApprovalStatus == 'Approved' ? accentGreen : 
                        model.overallApprovalStatus == 'Rejected' ? Colors.red.shade600 : 
                        statusPendingColor; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _showApprovalDialog(context, model), // Open detailed review
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP ROW: Name (Role) & Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${model.userName} (${model.userRole})",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      model.userEmail, 
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 15),

                // 1. TRAVEL DETAILS SUMMARY
                _buildApprovalItemSummary(
                  "Travel",
                  model.travelDate ?? 'N/A', 
                  model.travelStatus ?? 'Pending',
                  model.travelAmount ?? 0.0,
                ),
                
                const Divider(height: 10, color: Color(0xFFE0E0E0)),

                // 2. ACCOMMODATION DETAILS SUMMARY
                _buildApprovalItemSummary(
                  "Accommodation",
                  model.stayDate ?? 'N/A', 
                  model.stayStatus ?? 'Pending',
                  model.stayAmount ?? 0.0,
                ),
                
                const SizedBox(height: 15),

                // OVERALL STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Overall Status:", style: TextStyle(fontWeight: FontWeight.bold, color: darkGreyText)),
                    Text(
                      model.overallApprovalStatus ?? 'Pending', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),

                // OVERALL ALLOCATED AMOUNT
                if ((model.travelAmount ?? 0.0) + (model.stayAmount ?? 0.0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Allocated:", style: TextStyle(fontWeight: FontWeight.bold, color: darkGreyText)),
                        Text("₹ ${(model.travelAmount! + model.stayAmount!).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),
                const Text("Tap anywhere to open Review Dialog", style: TextStyle(fontSize: 11, color: Colors.black54)),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build the summary row for Travel/Stay (simpler than full dialog)
  Widget _buildApprovalItemSummary(
    String title, 
    String dateDetail,
    String status, 
    double currentAmount,
  ) {
    Color statusColor = status == 'Approved' ? accentGreen : (status == 'Rejected' ? Colors.red : statusPendingColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title (Date: $dateDetail)",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (status != 'Pending')
                  Text(
                    status == 'Approved' 
                        ? "Allocated: ₹ ${currentAmount.toStringAsFixed(2)}"
                        : "Rejected",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
              ],
            ),
          ),
          
          Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------- BUILD METHOD ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header structure
            Container(
              color: primaryPurple, 
              padding: const EdgeInsets.only(top: 32, left: 9, right: 18, bottom: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => AdminDashboardScreen(
                          userName: widget.userName,
                          userEmail: widget.userEmail,
                          userRole: widget.userRole,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text("ExamDuty+", style: TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Container(width: 43, height: 43, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)), child: const Center(child: Icon(Icons.school_rounded, color: primaryPurple, size: 24))),
                ],
              ),
            ),
            
            // Honorarium Summary pill
            Container(
              width: 327,
              height: 51,
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: accentGreen, 
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  "Honorarium Summary",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: FutureBuilder<List<HonorariumModel>>(
                future: _fetchPendingSubmissions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                  }

                  final submissions = snapshot.data ?? [];

                  if (submissions.isEmpty) {
                    return const Center(
                      child: Text("No honorarium submissions currently pending review.", style: TextStyle(color: darkGreyText)),
                    );
                  }

                  return ListView.builder(
                    itemCount: submissions.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      return _buildUserSummaryCard(submissions[index]);
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