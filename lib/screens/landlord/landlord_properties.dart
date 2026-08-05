import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/colors.dart';
import '../../utils/models/landlord_profile.dart';
import '../../utils/providers/landlord_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import 'property_details_screen.dart';

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
  String _error = '';
  var token = SharedPrefrenceBuilder.getUserToken;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      isLoading = true;
      _error = '';
    });
    try {
      final response = await LandlordProvider().getProperties();
      if (!mounted) return;
      if (response['status'] == true && response['properties'] != null) {
        setState(() {
          properties = (response['properties'] as List)
              .map((p) => Property.fromJson(p))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message']?.toString() ??
              'Could not load your properties.';
          isLoading = false;
        });
      }
    } catch (error) {
      log(error.toString(), name: "ERROR LOADING PROPERTIES");
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your properties. Check your connection.';
        isLoading = false;
      });
    }
  }

  Future<void> _showAddPropertyDialog() async {
    final created = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddPropertySheet(),
    );
    if (!mounted) return;
    if (created != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(created)));
      _loadProperties();
    }
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
                  : _error.isNotEmpty
                      ? _buildErrorState()
                      : (properties == null || properties!.isEmpty)
                          ? RefreshIndicator(
                              onRefresh: _loadProperties,
                              color: royalBlue,
                              child: _buildEmptyState(),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadProperties,
                              color: royalBlue,
                              child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: properties!.length,
                          itemBuilder: (context, index) {
                            final property = properties![index];
                            return InkWell(
                              onTap: () => Navigator.pushNamed(
                                context,
                                PropertyDetailsScreen.routeName,
                                arguments: {'property': property},
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Card(
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
                            ));
                          },
                        )),
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

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apartment, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No properties yet',
              style: GoogleFonts.hind(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Pull down to refresh, or add your first property.',
              textAlign: TextAlign.center,
              style: GoogleFonts.hind(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Could not load properties',
              style:
                  GoogleFonts.hind(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: GoogleFonts.hind(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProperties,
              style: ElevatedButton.styleFrom(backgroundColor: royalBlue),
              child:
                  const Text('Retry', style: TextStyle(color: Colors.white)),
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

/// Bottom-sheet form to create a property (block) and bulk-create its units.
/// All units get the same rent + service charge (numbered 1..N); individual
/// units can be edited afterwards via the Add House screen. Pops a summary
/// string on success, or null if cancelled.
class AddPropertySheet extends StatefulWidget {
  const AddPropertySheet({super.key});

  @override
  State<AddPropertySheet> createState() => _AddPropertySheetState();
}

class _AddPropertySheetState extends State<AddPropertySheet> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _unitsCtrl = TextEditingController(text: '1');
  final _rentCtrl = TextEditingController();
  final _serviceCtrl = TextEditingController();

  bool _submitting = false;
  String? _status;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _unitsCtrl.dispose();
    _rentCtrl.dispose();
    _serviceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final units = int.tryParse(_unitsCtrl.text.trim()) ?? 0;
    final rent = _rentCtrl.text.trim();
    final service = _serviceCtrl.text.trim();

    if (name.isEmpty || location.isEmpty) {
      setState(() => _error = 'Enter a property name and location.');
      return;
    }
    if (units < 1) {
      setState(() => _error = 'Number of units must be at least 1.');
      return;
    }
    if ((double.tryParse(rent) ?? -1) < 0 ||
        (double.tryParse(service) ?? -1) < 0) {
      setState(() => _error = 'Enter valid rent and service charge amounts.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
      _status = 'Creating property…';
    });
    final navigator = Navigator.of(context);
    final provider = LandlordProvider();

    try {
      final res = await provider.addProperty(name, location);
      if (!mounted) return;
      if (res['status'] != true) {
        setState(() {
          _submitting = false;
          _error = res['message']?.toString() ?? 'Could not create property.';
        });
        return;
      }

      var created = 0;
      final failures = <String>[];
      for (var i = 1; i <= units; i++) {
        if (!mounted) return;
        setState(() => _status = 'Adding unit $i of $units…');
        try {
          final hr = await provider.addHouse(name, '$i', service, rent, context);
          if (hr.status == true) {
            created++;
          } else {
            failures.add('$i');
          }
        } catch (_) {
          failures.add('$i');
        }
      }

      if (!mounted) return;
      final msg = failures.isEmpty
          ? '$name created with $created unit${created == 1 ? '' : 's'}.'
          : '$name created — $created/$units units added (failed: ${failures.join(', ')}).';
      navigator.pop(msg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Add Property',
                style: GoogleFonts.hind(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: royalBlue)),
            const SizedBox(height: 4),
            Text(
              'Create a block and its units. Every unit gets the same rent & '
              'service charge — you can edit individual units later.',
              style: GoogleFonts.hind(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            _field(_nameCtrl, 'Property / block name', hint: 'e.g. Block A1'),
            const SizedBox(height: 12),
            _field(_locationCtrl, 'Location', hint: 'e.g. Akilla Estate'),
            const SizedBox(height: 12),
            _field(_unitsCtrl, 'Number of units (flats)',
                keyboardType: TextInputType.number, hint: 'e.g. 5'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(_rentCtrl, 'Rent / unit (KES)',
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(_serviceCtrl, 'Service / unit (KES)',
                      keyboardType: TextInputType.number),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 18, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: GoogleFonts.hind(
                              fontSize: 12, color: Colors.red.shade700)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: royalBlue,
                  disabledBackgroundColor: royalBlue.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(_status ?? 'Working…',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.hind(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      )
                    : Text('Create property',
                        style: GoogleFonts.hind(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? keyboardType, String? hint}) {
    return TextField(
      controller: c,
      enabled: !_submitting,
      keyboardType: keyboardType,
      style: GoogleFonts.hind(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: royalBlue),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
