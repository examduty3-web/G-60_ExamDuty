// bank_details.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'dashboard_screen.dart'; 

class BankDetailsScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole; 

  const BankDetailsScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _holderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _confirmAccountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();

  bool _isLoading = false;
  String? _accountMismatchError;

  @override
  void initState() {
    super.initState();
    _accountNumberController.addListener(_validateAccountMatch);
    _confirmAccountNumberController.addListener(_validateAccountMatch);
    _loadBankDetails(); // Load existing data
  }

  // --- DATA LOADING (READ) LOGIC ---
  Future<void> _loadBankDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !mounted) return;

    try {
      // Accessing the document unique to the current user's UID
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()?['bankDetails'] as Map<String, dynamic>?;
        
        if (data != null && mounted) {
          setState(() {
            _holderNameController.text = data['holderName'] ?? '';
            _accountNumberController.text = data['accountNumber'] ?? '';
            _confirmAccountNumberController.text = data['accountNumber'] ?? '';
            _ifscController.text = data['ifscCode'] ?? '';
            _bankNameController.text = data['bankName'] ?? '';
            _branchNameController.text = data['branchName'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading bank details: $e');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load previous data.')),
        );
      }
    }
  }

  // --- VALIDATION LOGIC (unchanged) ---
  void _validateAccountMatch() {
    final acc = _accountNumberController.text.trim();
    final conf = _confirmAccountNumberController.text.trim();

    String? newError;
    if (acc.isNotEmpty && conf.isNotEmpty && acc != conf) {
      newError = "Account number did not match";
    }

    if (newError != _accountMismatchError) {
      setState(() {
        _accountMismatchError = newError;
      });
    }
  }

  bool get _canSubmit {
    return _holderNameController.text.trim().isNotEmpty &&
        _accountNumberController.text.trim().isNotEmpty &&
        _confirmAccountNumberController.text.trim().isNotEmpty &&
        _ifscController.text.trim().isNotEmpty &&
        _bankNameController.text.trim().isNotEmpty &&
        _branchNameController.text.trim().isNotEmpty &&
        _accountMismatchError == null;
  }

  // --- SUBMISSION LOGIC (unchanged) ---
  Future<void> _submitBankDetails() async {
    if (!_formKey.currentState!.validate()) return;
    if (_accountMismatchError != null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; 

    setState(() => _isLoading = true);

    try {
      final bankData = {
        'holderName': _holderNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'ifscCode': _ifscController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'branchName': _branchNameController.text.trim(),
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'bankDetails': bankData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); 

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Bank Details Updated"),
          content: const Text(
            "Your bank details have been updated successfully for honorarium payment.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(
                      userName: widget.userName,
                      userEmail: widget.userEmail,
                      userRole: widget.userRole,
                    ),
                  ),
                );
              },
              child: const Text("Okay"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save details: ${e.toString()}. Check Firebase Rules.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _holderNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
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
                Container(width: double.infinity, height: 110, color: const Color(0xFF5335EA)),
                Padding(
                  padding: const EdgeInsets.only(top: 32, left: 9, right: 18),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => DashboardScreen(
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
                      Container(
                        width: 43, height: 43,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 3))]),
                        child: Center(
                          child: Container(
                            width: 25, height: 25,
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

            // ❌ REMOVED: Subject Card was here

            // MAIN FORM
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 5),
                  child: Form(
                    key: _formKey,
                    onChanged: () => setState(() {}),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFBEBEC7), width: 1)),
                      padding: const EdgeInsets.fromLTRB(18, 21, 18, 21),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bank Details Header
                          const Text("Bank Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.3)),
                          const SizedBox(height: 5),
                          const Text("Enter your bank account details for exam duty honorarium payment", style: TextStyle(fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 16),

                          // Info box (UI elements preserved)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(color: const Color(0xFFFFF7E8), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3C27C), width: 1)),
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Icon(Icons.info_outline_rounded, color: Color(0xFFE59C3A), size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Important Information", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: Color(0xFFB56C14))),
                                      SizedBox(height: 3),
                                      Text("Please ensure all details are accurate. Payments will be processed to this account.", style: TextStyle(fontSize: 12.3, color: Color(0xFF8A6B3A))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // FIELDS (UI elements preserved)
                          _BankField(label: "Account Holder Name", hint: "As per bank records", controller: _holderNameController, keyboardType: TextInputType.name),
                          const SizedBox(height: 14),
                          _BankField(label: "Account Number", hint: "Enter your account number", controller: _accountNumberController, keyboardType: TextInputType.number, obscureText: true, digitsOnly: true),
                          const SizedBox(height: 14),
                          _BankField(label: "Confirm Account Number", hint: "Re-enter your account number", controller: _confirmAccountNumberController, keyboardType: TextInputType.number, obscureText: false, digitsOnly: true),

                          // Mismatch Error Display
                          if (_accountMismatchError != null) ...[
                            const SizedBox(height: 4),
                            Text(_accountMismatchError!, style: const TextStyle(color: Colors.red, fontSize: 12.5)),
                          ],

                          const SizedBox(height: 14),
                          _BankField(label: "IFSC Code", hint: "e.g., SBIN0001234", controller: _ifscController, keyboardType: TextInputType.text),
                          const SizedBox(height: 14),
                          _BankField(label: "Bank Name", hint: "e.g., State Bank of India", controller: _bankNameController, keyboardType: TextInputType.text),
                          const SizedBox(height: 14),
                          _BankField(label: "Branch Name", hint: "e.g., Pilani Main Branch", controller: _branchNameController, keyboardType: TextInputType.text),
                          const SizedBox(height: 22),

                          // SUBMIT BUTTON
                          Center(
                            child: SizedBox(
                              width: 250, height: 51,
                              child: ElevatedButton(
                                onPressed: (_canSubmit && !_isLoading) ? _submitBankDetails : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5335EA),
                                  disabledBackgroundColor: const Color(0xFFB5B6C6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Submit Bank Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
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
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => DashboardScreen(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                    userRole: widget.userRole, 
                  ),
                ),
              );
            },
          ),
          _NavItem(
            icon: Icons.account_balance_rounded, 
            label: "Bank Details",
            onTap: () { 
              // Currently on Bank Details screen. Do nothing.
            }
          ),
          _NavItem(
            icon: Icons.account_balance_wallet_rounded, 
            label: "Honorarium Status",
            onTap: () {
              // Placeholder logic
              debugPrint("Honorarium tapped");
            }
          ),
          _NavItem(
            icon: Icons.person_rounded, 
            label: "My Profile",
            onTap: () {
              // Placeholder logic
              debugPrint("Profile tapped");
            }
          ),
        ],
      ),
    );
  }
}

class _BankField extends StatelessWidget {
// ... (BankField implementation is correct)
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool digitsOnly;

  const _BankField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.digitsOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIX: Replaced Text with RichText to show the mandatory asterisk
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.5, fontWeight: FontWeight.w500),
            children: [
              // Display the label text
              TextSpan(text: label),
              // Add the red asterisk (mandatory required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: digitsOnly
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ]
              : null,
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