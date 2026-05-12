import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/colors.dart';
import '../../utils/models/landlord_profile.dart';
import '../../utils/providers/landlord_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';

class LandlordPropertiesScreen extends StatefulWidget {
  static const routeName = "/landlord-properties";

  const LandlordPropertiesScreen({super.key});

  @override
  State<LandlordPropertiesScreen> createState() =>
      _LandlordPropertiesScreenState();
}

class _LandlordPropertiesScreenState extends State<LandlordPropertiesScreen> {
  List<Property>? properties;
  bool isLoading = true;
  var token = SharedPrefrenceBuilder.getUserToken;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    final profile = LandlordProvider().getProfile(token!, context);
    profile.then((value) {
      if (mounted) {
        setState(() {
          properties = value.profile?.properties;
          isLoading = false;
        });
      }
    }).catchError((error) {
      log(error.toString(), name: "ERROR LOADING PROPERTIES");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'My Properties',
                style: GoogleFonts.hind(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: royalBlue,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: royalBlue,
                      ),
                    )
                  : properties == null || properties!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.apartment,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No properties yet',
                                style: GoogleFonts.hind(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: properties!.length,
                          itemBuilder: (context, index) {
                            final property = properties![index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.apartment,
                                          color: royalBlue,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Block ${property.blockNumber}',
                                                style: GoogleFonts.hind(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    property.location ?? 'N/A',
                                                    style: GoogleFonts.hind(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildInfoItem(
                                          icon: Icons.home,
                                          label: 'Total Houses',
                                          value: property.totalHouses?.toString() ?? '0',
                                        ),
                                        _buildInfoItem(
                                          icon: Icons.numbers,
                                          label: 'Block ID',
                                          value: property.id?.toString() ?? 'N/A',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: royalBlue,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.hind(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.hind(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
