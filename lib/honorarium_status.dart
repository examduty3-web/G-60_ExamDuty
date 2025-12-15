import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';
import 'honorarium_model.dart';
import 'package:intl/intl.dart';

final CollectionReference honorariumCollection = 
    FirebaseFirestore.instance.collection('travel_requests');

class HonorariumStatusScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final String userId; 

  const HonorariumStatusScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.userId, 
  });

  // Fetch the user's specific submission status
  Future<HonorariumModel?> _fetchUserStatus() async {
    // We assume the document ID is the user's UID for efficiency
    final doc = await honorariumCollection.doc(userId).get();
    
    if (doc.exists) {
      return HonorariumModel.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
  
  // 🚨 NEW WIDGET: Dialog to show the specific amount on click
  void _showAmountDialog(BuildContext context, String category, double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("$category Allocation"),
        content: Text(
          "The approved amount for $category is: ₹ ${amount.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  // 🚨 UPDATED WIDGET: Helper to build the status row with click action
  Widget _buildStatusRow(BuildContext context, String label, String status, double amount) {
    IconData icon;
    Color color;
    VoidCallback? onTap;

    switch (status) {
      case 'Approved':
        icon = Icons.check_circle_rounded;
        color = Colors.green.shade600;
        // Only allow click if approved and amount is greater than zero
        if (amount > 0) {
          onTap = () => _showAmountDialog(context, label, amount);
        }
        break;
      case 'Rejected':
        icon = Icons.cancel_rounded;
        color = Colors.red.shade600;
        break;
      case 'Pending':
      default:
        icon = Icons.access_time_filled_rounded;
        color = Colors.orange.shade600;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 5),
                Text(
                  // Show "View Amount" if approved and clickable, otherwise show status
                  (status == 'Approved' && amount > 0) ? "View Amount" : status, 
                  style: TextStyle(
                    color: color, 
                    fontWeight: FontWeight.w500,
                    decoration: onTap != null ? TextDecoration.underline : null, // Indicate clickability
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 🚨 NEW WIDGET: Builds the primary header pill section
  Widget _buildHeaderPill() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      // Green gradient/color from the design
      decoration: BoxDecoration(
        color: const Color(0xFF54B478),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          "Honorarium Status",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ExamDuty+", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF5335EA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DashboardScreen(
                userName: userName,
                userEmail: userEmail,
                userRole: userRole,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
              child: const Center(child: Icon(Icons.school_rounded, color: Color(0xFF5335EA), size: 24)),
            ),
          )
        ],
      ),
      body: FutureBuilder<HonorariumModel?>(
        future: _fetchUserStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching status: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          
          final model = snapshot.data;

          if (model == null || model.overallApprovalStatus == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "No Honorarium claim details submitted yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            );
          }

          // Total approved amount display
          final double totalApproved = model.allocatedAmount ?? 0.0;
          final bool isOverallApproved = model.overallApprovalStatus == 'Approved';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeaderPill(),
                const SizedBox(height: 20),
                
                Card(
                  elevation: 0, // Using minimal elevation to match design
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Subject Details ---
                        const Text(
                          "Name of the Subject",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          model.travelDetails ?? "Course Code N/A",
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        
                        const SizedBox(height: 15),

                        // --- Total Approved Amount Chip (Matching Design) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Allocation:", style: TextStyle(fontSize: 14, color: Colors.black87)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isOverallApproved ? Colors.green.shade100 : Colors.orange.shade100, // Use green only if approved
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "₹ ${totalApproved.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: isOverallApproved ? Colors.green.shade700 : Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 25),
                        
                        // --- Status Rows (Travel and Stay) ---
                        // Travel Status Row (Clickable for amount)
                        _buildStatusRow(
                          context, 
                          "Travel", 
                          model.travelStatus ?? 'Pending',
                          model.travelAmount ?? 0.0,
                        ),
                        const SizedBox(height: 10),
                        
                        // Accommodation Status Row (Clickable for amount)
                        _buildStatusRow(
                          context, 
                          "Accommodation", 
                          model.stayStatus ?? 'Pending',
                          model.stayAmount ?? 0.0,
                        ),
                        
                        const SizedBox(height: 15),

                        // --- Submission/Review Date ---
                        if (model.submissionDate != null)
                          Text(
                            "Last Reviewed: ${DateFormat('MMM d, y - h:mm a').format(model.submissionDate!.toDate().toLocal())}",
                            style: const TextStyle(fontSize: 12, color: Colors.black54)
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // 🚨 User Bottom Nav (Placeholder - usually handled by the main app shell)
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.grey[100],
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
                Icon(Icons.home_rounded, color: Color(0xFF196BDE)),
                Icon(Icons.account_balance_rounded, color: Color(0xFF196BDE)),
                Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF196BDE)),
                Icon(Icons.person_rounded, color: Color(0xFF196BDE)),
            ],
        ),
      ),
    );
  }
}