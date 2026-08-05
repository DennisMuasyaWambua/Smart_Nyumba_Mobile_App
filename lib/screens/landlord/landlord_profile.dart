import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/colors.dart';
import '../../../widgets/profile_avatar.dart';
import '../../utils/providers/landlord_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../authentication/login.dart';

class LandlordProfileScreen extends StatefulWidget {
  static const routeName = "/landlord-profile";

  const LandlordProfileScreen({super.key});

  @override
  State<LandlordProfileScreen> createState() => _LandlordProfileScreenState();
}

class _LandlordProfileScreenState extends State<LandlordProfileScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String mobileNumber = '';
  String idNumber = '';
  int totalProperties = 0;
  bool isLoading = true;
  var token = SharedPrefrenceBuilder.getUserToken;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = LandlordProvider().getProfile(token!, context);
    profile.then((value) {
      log('Profile data received: ${value.toJson().toString()}', name: 'PROFILE DATA');
      if (mounted) {
        setState(() {
          firstName = value.profile?.user?.firstName ?? '';
          lastName = value.profile?.user?.lastName ?? '';
          email = value.profile?.user?.email ?? '';
          mobileNumber = value.profile?.user?.mobileNumber ?? '';
          idNumber = value.profile?.landlord?.idNumber ?? '';
          totalProperties = value.profile?.properties?.length ?? 0;
          isLoading = false;

          log('First Name: $firstName', name: 'PROFILE PARSED');
          log('Last Name: $lastName', name: 'PROFILE PARSED');
          log('Email: $email', name: 'PROFILE PARSED');
          log('Mobile: $mobileNumber', name: 'PROFILE PARSED');
          log('ID: $idNumber', name: 'PROFILE PARSED');
        });
      }
    }).catchError((error) {
      log(error.toString(), name: "ERROR LOADING PROFILE");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await LandlordProvider().logout(context);
              if (success && mounted) {
                Navigator.of(context).pushReplacementNamed(Login.routeName);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: royalBlue,
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Profile',
                        style: GoogleFonts.hind(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: royalBlue,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ProfileAvatar(
                        initial: firstName.isNotEmpty ? firstName : 'L',
                        radius: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$firstName $lastName',
                        style: GoogleFonts.hind(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: royalBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Landlord',
                          style: GoogleFonts.hind(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: royalBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildInfoCard(
                        icon: Icons.email,
                        label: 'Email',
                        value: email,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.phone,
                        label: 'Mobile Number',
                        value: mobileNumber,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.credit_card,
                        label: 'ID Number',
                        value: idNumber,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.apartment,
                        label: 'Total Properties',
                        value: totalProperties.toString(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: GoogleFonts.hind(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: royalBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: royalBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.hind(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.hind(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
