import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/colors.dart';
import '../../utils/models/landlord_profile.dart';
import '../../utils/providers/internet_checker.dart';
import '../../utils/providers/landlord_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../widgets/auth/register_input_field.dart';
import '../../widgets/button_layout.dart';

class AddHouseScreen extends StatefulWidget {
  static const routeName = "/add-house";

  const AddHouseScreen({super.key});

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  late TextEditingController _houseNumberController;
  late TextEditingController _serviceChargeController;
  late TextEditingController _rentChargedController;

  String? selectedBlock;
  List<Property>? properties;
  bool isLoading = false;
  bool isLoadingProperties = true;
  String errorString = "";
  String successString = "";

  var token = SharedPrefrenceBuilder.getUserToken;

  @override
  void initState() {
    super.initState();
    _houseNumberController = TextEditingController();
    _serviceChargeController = TextEditingController();
    _rentChargedController = TextEditingController();
    _loadProperties();
  }

  void _loadProperties() {
    final profile = LandlordProvider().getProfile(token!, context);
    profile.then((value) {
      if (mounted) {
        setState(() {
          properties = value.profile?.properties;
          isLoadingProperties = false;
        });
      }
    }).catchError((error) {
      log(error.toString(), name: "ERROR LOADING PROPERTIES");
      if (mounted) {
        setState(() {
          isLoadingProperties = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _houseNumberController.dispose();
    _serviceChargeController.dispose();
    _rentChargedController.dispose();
    super.dispose();
  }

  void _addHouse() async {
    if (selectedBlock == null ||
        _houseNumberController.text.isEmpty ||
        _serviceChargeController.text.isEmpty ||
        _rentChargedController.text.isEmpty) {
      setState(() {
        errorString = "All fields are required";
        successString = "";
      });
      return;
    }

    if (!Provider.of<InternetChecker>(context, listen: false).isInternetActive) {
      Provider.of<InternetChecker>(context, listen: false)
          .showInternetConnectionDialog(context);
      return;
    }

    setState(() {
      isLoading = true;
      errorString = "";
      successString = "";
    });

    try {
      final response = await LandlordProvider().addHouse(
        selectedBlock!,
        _houseNumberController.text,
        _serviceChargeController.text,
        _rentChargedController.text,
        context,
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        if (response.status == true) {
          setState(() {
            successString = response.message ?? "House added successfully";
            errorString = "";
          });

          // Clear form
          _houseNumberController.clear();
          _serviceChargeController.clear();
          _rentChargedController.clear();
          setState(() {
            selectedBlock = null;
          });

          // Show success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: Text(successString),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          setState(() {
            errorString = response.message ?? "Failed to add house";
            successString = "";
          });
        }
      }
    } catch (e) {
      log(e.toString(), name: "ERROR ADDING HOUSE");
      if (mounted) {
        setState(() {
          isLoading = false;
          errorString = "An error occurred while adding the house";
          successString = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New House',
                  style: GoogleFonts.hind(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a house to your property block',
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                if (isLoadingProperties)
                  const Center(
                    child: CircularProgressIndicator(
                      color: royalBlue,
                    ),
                  )
                else if (properties == null || properties!.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.apartment,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No properties available',
                          style: GoogleFonts.hind(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contact admin to assign properties to you',
                          style: GoogleFonts.hind(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    'Select Block',
                    style: GoogleFonts.hind(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                      value: selectedBlock,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.apartment,
                          color: royalBlue,
                        ),
                        hintText: "Select a block",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                      items: properties!.map((property) {
                        return DropdownMenuItem<String>(
                          value: property.blockNumber,
                          child: Text(
                              'Block ${property.blockNumber} - ${property.location}'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBlock = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  RegisterInputField(
                    controller: _houseNumberController,
                    prefixIcon: Icons.house,
                    hintText: "House Number (e.g., A1, B2)",
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  RegisterInputField(
                    controller: _serviceChargeController,
                    prefixIcon: Icons.monetization_on,
                    hintText: "Service Charge (KES)",
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  RegisterInputField(
                    controller: _rentChargedController,
                    prefixIcon: Icons.attach_money,
                    hintText: "Rent Amount (KES)",
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),
                  ButtonLayout(
                    width: double.infinity,
                    height: 56,
                    text: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Add House',
                            style: GoogleFonts.hind(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                    onClick: isLoading ? () {} : _addHouse,
                  ),
                  const SizedBox(height: 16),
                  if (errorString.isNotEmpty)
                    Center(
                      child: Text(
                        errorString,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (successString.isNotEmpty)
                    Center(
                      child: Text(
                        successString,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
