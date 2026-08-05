import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/colors.dart';
import '../../utils/models/landlord_profile.dart';
import '../../utils/providers/internet_checker.dart';
import '../../utils/providers/landlord_provider.dart';
import '../../widgets/auth/register_input_field.dart';
import '../../widgets/button_layout.dart';

class OnboardTenantScreen extends StatefulWidget {
  static const routeName = '/onboard-tenant';
  const OnboardTenantScreen({super.key});

  @override
  State<OnboardTenantScreen> createState() => _OnboardTenantScreenState();
}

class _OnboardTenantScreenState extends State<OnboardTenantScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _emailController;

  String? _selectedBlockNumber;
  String? _selectedHouseNumber;
  List<Property>? _properties;
  List<String>? _availableHouses;
  bool _isLoadingProperties = true;
  bool _isLoadingHouses = false;
  bool _isSubmitting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _idNumberController = TextEditingController();
    _mobileNumberController = TextEditingController();
    _emailController = TextEditingController();
    _loadProperties();
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

  void _loadProperties() {
    final propertiesResponse = LandlordProvider().getProperties();
    propertiesResponse.then((response) {
      if (mounted) {
        setState(() {
          if (response['status'] == true && response['properties'] != null) {
            _properties = (response['properties'] as List)
                .map((p) => Property.fromJson(p))
                .toList();
          }
          _isLoadingProperties = false;
        });
      }
    }).catchError((error) {
      log(error.toString(), name: "ERROR LOADING PROPERTIES");
      if (mounted) {
        setState(() {
          _isLoadingProperties = false;
        });
      }
    });
  }

  void _loadHousesForBlock(String blockNumber) async {
    setState(() {
      _isLoadingHouses = true;
      _selectedHouseNumber = null;
      _availableHouses = null;
    });

    try {
      // Call API to get available houses
      final response = await LandlordProvider().getAvailableHouses(blockNumber);

      if (mounted) {
        setState(() {
          if (response['status'] == true && response['available_houses'] != null) {
            // Extract house numbers from the response
            _availableHouses = (response['available_houses'] as List)
                .map((house) => house['house_number'] as String)
                .toList();
          } else {
            _availableHouses = [];
          }
          _isLoadingHouses = false;
        });
      }
    } catch (e) {
      log(e.toString(), name: "ERROR LOADING HOUSES");
      if (mounted) {
        setState(() {
          _availableHouses = [];
          _isLoadingHouses = false;
        });
      }
    }
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _idNumberController.text.isEmpty ||
        _mobileNumberController.text.isEmpty ||
        _selectedBlockNumber == null ||
        _selectedHouseNumber == null) {
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

    // Mobile number validation (should start with 254 or be 9 digits)
    final mobile = _mobileNumberController.text.trim();
    if (mobile.isEmpty) {
      setState(() {
        _errorMessage = 'Mobile number is required';
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
    try {
      final internetChecker = Provider.of<InternetChecker>(context, listen: false);
      if (!internetChecker.isInternetActive) {
        internetChecker.showInternetConnectionDialog(context);
        return;
      }
    } catch (e) {
      // InternetChecker not available, continue anyway
      log("InternetChecker not available: ${e.toString()}", name: "Onboard Tenant");
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final response = await LandlordProvider().onboardTenant(
        _emailController.text,
        _firstNameController.text,
        _lastNameController.text,
        _idNumberController.text,
        _mobileNumberController.text,
        _selectedBlockNumber!,
        _selectedHouseNumber!,
        context,
      );

      setState(() {
        _isSubmitting = false;
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
                    'Tenant Onboarded!',
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
                    response.message ?? 'Tenant onboarded successfully!',
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
                            Icon(Icons.person, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${_firstNameController.text} ${_lastNameController.text}',
                                style: GoogleFonts.hind(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _emailController.text,
                                style: GoogleFonts.hind(
                                  fontSize: 12,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.home, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Block $_selectedBlockNumber, House $_selectedHouseNumber',
                              style: GoogleFonts.hind(
                                fontSize: 12,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.lock_outline, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Login credentials sent via email',
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
                    'The tenant can now login to the tenant portal with their email and the password sent to them.',
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
                    Navigator.of(context).pop(); // Go back
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
          _errorMessage = response.message ?? 'Onboarding failed';
        });
      }
    } catch (e) {
      log(e.toString(), name: "Onboard Tenant Error");
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: royalBlue,
        title: Text(
          'Onboard New Tenant',
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
                'Add a new tenant to a house',
                style: GoogleFonts.hind(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: royalBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The tenant will receive login credentials via email',
                style: GoogleFonts.hind(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Property and House Selection
              if (_isLoadingProperties)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: royalBlue),
                  ),
                )
              else if (_properties == null || _properties!.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No properties available. Please add properties first.',
                          style: GoogleFonts.hind(
                            fontSize: 13,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Block selection
                Text(
                  'Select Property Block',
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedBlockNumber,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.apartment, color: royalBlue),
                      hintText: "Select a block",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                    ),
                    items: _properties!.map((property) {
                      return DropdownMenuItem<String>(
                        value: property.blockNumber,
                        child: Text(
                            'Block ${property.blockNumber} - ${property.location}'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBlockNumber = newValue;
                        _selectedHouseNumber = null;
                      });
                      if (newValue != null) {
                        _loadHousesForBlock(newValue);
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // House selection
                if (_selectedBlockNumber != null) ...[
                  Text(
                    'Select House',
                    style: GoogleFonts.hind(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingHouses)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: royalBlue),
                      ),
                    )
                  else if (_availableHouses == null ||
                      _availableHouses!.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No available houses in this block.',
                              style: GoogleFonts.hind(
                                fontSize: 13,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedHouseNumber,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.house, color: royalBlue),
                          hintText: "Select a house",
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                        ),
                        items: _availableHouses!.map((house) {
                          return DropdownMenuItem<String>(
                            value: house,
                            child: Text('House $house'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedHouseNumber = newValue;
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                ],

                // Tenant details form
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
                  hintText: "Mobile Number (0712345678)",
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
                  onClick: _isSubmitting ? () {} : _submitForm,
                  text: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          'Onboard Tenant',
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
            ],
          ),
        ),
      ),
    );
  }
}
