import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/api/api_client.dart';
import 'dart:convert';

import '../../utils/constants/constants.dart';
import '../../utils/providers/shared_preference_builder.dart';

class TenantManagementScreen extends StatefulWidget {
  static const routeName = "/landlord-tenant-management";

  const TenantManagementScreen({super.key});

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _tenants = [];
  List<dynamic> _filteredTenants = [];
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      String? token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        throw Exception("No authentication token found");
      }

      Uri uri = Uri.parse(Constants.ALL_TENANTS_URL);
      final response = await SafeHttp.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      log(response.statusCode.toString(), name: "Tenants status code");
      log(response.body.toString(), name: "Tenants response");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            // Backend returns 'tenant' (singular) not 'tenants'
            _tenants = data['tenant'] ?? [];
            _filteredTenants = _tenants;
            _isLoading = false;
          });
        }
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to load tenants');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        log(e.toString(), name: "ERROR LOADING TENANTS");
      }
    }
  }

  void _filterTenants() {
    setState(() {
      _filteredTenants = _tenants.where((tenant) {
        // Search filter
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          String name = tenant['name']?.toString().toLowerCase() ?? '';
          String email = tenant['email']?.toString().toLowerCase() ?? '';
          String query = _searchQuery.toLowerCase();
          matchesSearch = name.contains(query) || email.contains(query);
        }

        // Status filter
        bool matchesStatus = true;
        if (_selectedFilter != 'all') {
          int isActive = tenant['is_active'] ?? 0;
          if (_selectedFilter == 'active') {
            matchesStatus = isActive == 1;
          } else if (_selectedFilter == 'inactive') {
            matchesStatus = isActive == 0;
          }
        }

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  /// The nested property-block map, tolerant of either JSON key casing.
  Map<String, dynamic>? _pb(Map tenant) {
    final pb = tenant['PropertyBlock'] ?? tenant['property_block'];
    return pb is Map ? Map<String, dynamic>.from(pb) : null;
  }

  Map<String, dynamic>? _block(Map tenant) {
    final b = _pb(tenant)?['block'];
    return b is Map ? Map<String, dynamic>.from(b) : null;
  }

  String _money(dynamic v) {
    final d = double.tryParse(v?.toString() ?? '');
    if (d == null) return 'N/A';
    return NumberFormat.currency(symbol: 'KES ', decimalDigits: 0).format(d);
  }

  String _date(dynamic v) {
    final s = v?.toString() ?? '';
    if (s.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  Widget _buildTenantCard(Map<String, dynamic> tenant) {
    final name = tenant['name'] ?? 'N/A';
    final email = tenant['email'] ?? 'N/A';
    final houseNumber = _pb(tenant)?['house_number'] ?? 'N/A';
    final block = _block(tenant)?['block_number'] ?? 'N/A';
    final isActive = tenant['is_active'] == 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green[100] : Colors.grey[300],
          child: Icon(
            Icons.person,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.hind(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.hind(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Block $block, House $houseNumber',
              style: GoogleFonts.hind(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'Active' : 'Inactive',
            style: GoogleFonts.hind(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green[800] : Colors.red[800],
            ),
          ),
        ),
        onTap: () {
          _showTenantDetails(tenant);
        },
      ),
    );
  }

  void _showTenantDetails(Map<String, dynamic> tenant) {
    final pb = _pb(tenant);
    final block = _block(tenant);
    final name = (tenant['name'] ?? 'Tenant').toString();
    final active = tenant['is_active'] == 1;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: active
                        ? Colors.green.shade100
                        : Colors.grey.shade300,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.hind(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.green.shade800 : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: GoogleFonts.hind(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Constants.themePurple)),
                        Text(
                          '${block?['block_number'] ?? 'N/A'} • House ${pb?['house_number'] ?? 'N/A'}',
                          style: GoogleFonts.hind(
                              fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: active ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(active ? 'Active' : 'Inactive',
                        style: GoogleFonts.hind(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.green.shade800
                                : Colors.red.shade800)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _detailSection('Occupancy', [
                _detailItem(Icons.apartment, 'Property / block',
                    '${block?['block_number'] ?? 'N/A'}'),
                _detailItem(Icons.location_on_outlined, 'Location',
                    '${block?['location'] ?? 'N/A'}'),
                _detailItem(Icons.home_outlined, 'House / unit',
                    '${pb?['house_number'] ?? 'N/A'}'),
                _detailItem(Icons.event_available_outlined,
                    'Property registered', _date(block?['registration_date'])),
              ]),
              const SizedBox(height: 8),
              _detailSection('Charges', [
                _detailItem(Icons.payments_outlined, 'Monthly rent',
                    _money(pb?['rent_charged'])),
                _detailItem(Icons.cleaning_services_outlined,
                    'Monthly service charge', _money(pb?['service_charge'])),
                _detailItem(Icons.calendar_month_outlined,
                    'Annual service charge', _money(pb?['annual_service_charge'])),
                _detailItem(Icons.schedule_outlined, 'Rent due date',
                    _date(pb?['rent_due_date'])),
              ]),
              const SizedBox(height: 8),
              _detailSection('Tenant', [
                _detailItem(Icons.email_outlined, 'Email',
                    '${tenant['email'] ?? 'N/A'}'),
                _detailItem(Icons.badge_outlined, 'ID number',
                    '${tenant['id_number'] ?? 'N/A'}'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.hind(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Constants.themePurple)),
          const SizedBox(height: 6),
          ...items,
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style:
                    GoogleFonts.hind(fontSize: 13, color: Colors.grey.shade700)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.hind(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tenant Management',
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTenants,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tenants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterTenants();
              },
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Inactive', 'inactive'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tenant list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading tenants',
                              style: GoogleFonts.hind(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _error,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.hind(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTenants,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredTenants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No tenants found',
                                  style: GoogleFonts.hind(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadTenants,
                            child: ListView.builder(
                              itemCount: _filteredTenants.length,
                              itemBuilder: (context, index) {
                                return _buildTenantCard(
                                  _filteredTenants[index]
                                      as Map<String, dynamic>,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _filterTenants();
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[800],
    );
  }
}
