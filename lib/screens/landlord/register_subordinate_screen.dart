import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/colors.dart';
import '../../utils/providers/internet_checker.dart';
import '../../utils/providers/landlord_provider.dart';
import '../../widgets/auth/register_input_field.dart';
import '../../widgets/button_layout.dart';

class RegisterSubordinateScreen extends StatefulWidget {
  static const routeName = '/register-subordinate';
  const RegisterSubordinateScreen({super.key});

  @override
  State<RegisterSubordinateScreen> createState() =>
      _RegisterSubordinateScreenState();
}

class _RegisterSubordinateScreenState extends State<RegisterSubordinateScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _emailController;

  String _selectedRole = 'accounts'; // Default to accountant
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _idNumberController = TextEditingController();
    _mobileNumberController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idNumberController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _idNumberController.text.isEmpty ||
        _mobileNumberController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return false;
    }

    // Basic email validation
    if (!_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email';
      });
      return false;
    }

    // Mobile number validation (should start with 254 and be 12 digits)
    final mobile = _mobileNumberController.text.trim();
    if (!mobile.startsWith('254') || mobile.length != 12) {
      setState(() {
        _errorMessage = 'Mobile number must be in format: 254XXXXXXXXX';
      });
      return false;
    }

    setState(() {
      _errorMessage = '';
    });
    return true;
  }

  void _submitForm() async {
    if (!_validateInputs()) {
      return;
    }

    // Check internet connection
    if (!Provider.of<InternetChecker>(context, listen: false)
        .isInternetActive) {
      Provider.of<InternetChecker>(context, listen: false)
          .showInternetConnectionDialog(context);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final landlordProvider = Provider.of<LandlordProvider>(context, listen: false);
      final response = await landlordProvider.registerSubordinate(
        _emailController.text,
        _firstNameController.text,
        _lastNameController.text,
        _idNumberController.text,
        _mobileNumberController.text,
        _selectedRole,
        context,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.status == true) {
        // Success - show dialog and go back
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Success!',
                    style: GoogleFonts.hind(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    response.message ?? 'Account created successfully!',
                    style: GoogleFonts.hind(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Email: ${response.email ?? _emailController.text}',
                                style: GoogleFonts.hind(
                                  fontSize: 12,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (response.assignedProperties != null && response.assignedProperties! > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.home_work_outlined, size: 16, color: Colors.blue[700]),
                              const SizedBox(width: 6),
                              Text(
                                'Assigned to ${response.assignedProperties} ${response.assignedProperties == 1 ? "property" : "properties"}',
                                style: GoogleFonts.hind(
                                  fontSize: 12,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.lock_outline, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Password sent via email',
                              style: GoogleFonts.hind(
                                fontSize: 12,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The ${_selectedRole == "accounts" ? "accountant" : "caretaker"} can now login with their email and the password sent to them.',
                    style: GoogleFonts.hind(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Registration failed';
        });
      }
    } catch (e) {
      log(e.toString(), name: "Register Subordinate Error");
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get role from navigation arguments (if passed)
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['role'] != null) {
      _selectedRole = args['role'];
    }

    final roleTitle = _selectedRole == 'accounts' ? 'Accountant' : 'Caretaker';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: royalBlue,
        title: Text(
          'Register $roleTitle',
          style: GoogleFonts.hind(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a new $roleTitle account',
                style: GoogleFonts.hind(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: royalBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This account will be linked to all your properties',
                style: GoogleFonts.hind(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Role selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline, color: royalBlue),
                    const SizedBox(width: 12),
                    Text(
                      'Role:',
                      style: GoogleFonts.hind(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Accountant'),
                              value: 'accounts',
                              groupValue: _selectedRole,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Caretaker'),
                              value: 'caretaker',
                              groupValue: _selectedRole,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form fields
              RegisterInputField(
                controller: _firstNameController,
                prefixIcon: Icons.person,
                hintText: "First Name",
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),

              RegisterInputField(
                controller: _lastNameController,
                prefixIcon: Icons.person,
                hintText: "Last Name",
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),

              RegisterInputField(
                controller: _idNumberController,
                prefixIcon: Icons.credit_card,
                hintText: "ID Number",
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),

              RegisterInputField(
                controller: _mobileNumberController,
                prefixIcon: Icons.phone,
                hintText: "Mobile Number (254XXXXXXXXX)",
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),

              RegisterInputField(
                controller: _emailController,
                prefixIcon: Icons.email,
                hintText: "Email",
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 12),

              // Note about password
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Password will be auto-generated and sent via email',
                        style: GoogleFonts.hind(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.hind(
                            fontSize: 13,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit button
              ButtonLayout(
                onClick: _isLoading ? () {} : _submitForm,
                text: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        'Create Account',
                        style: GoogleFonts.hind(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                borderRadius: 12,
                width: double.infinity,
                height: 50,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
