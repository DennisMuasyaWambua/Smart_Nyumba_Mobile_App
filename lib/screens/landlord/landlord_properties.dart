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
    final propertiesResponse = LandlordProvider().getProperties();
    propertiesResponse.then((response) {
      if (mounted) {
        setState(() {
          if (response['status'] == true && response['properties'] != null) {
            // Convert from API format to Property objects
            properties = (response['properties'] as List)
                .map((p) => Property(
                      id: p['id'],
                      blockNumber: p['block_number'],
                      location: p['location'],
                    ))
                .toList();
          }
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

  void _showAddPropertyDialog() {
    final blockController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Property',
          style: GoogleFonts.hind(
            fontWeight: FontWeight.w600,
            color: royalBlue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: blockController,
              decoration: const InputDecoration(
                labelText: 'Block Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: royalBlue,
            ),
            onPressed: () async {
              if (blockController.text.isEmpty ||
                  locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all fields')),
                );
                return;
              }

              try {
                final response = await LandlordProvider().addProperty(
                  blockController.text,
                  locationController.text,
                );

                if (response['status'] == true) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(response['message'] ??
                              'Property added successfully')),
                    );
                    _loadProperties(); // Reload properties
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(response['message'] ??
                              'Failed to add property')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Add Property', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPropertyDialog,
        backgroundColor: royalBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Property',
          style: TextStyle(color: Colors.white),
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
