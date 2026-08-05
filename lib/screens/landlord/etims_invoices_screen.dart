import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/colors.dart';
import '../../utils/models/subscription.dart';
import '../../utils/providers/subscription_provider.dart';
import '../../widgets/button_layout.dart';

class EtimsInvoicesScreen extends StatefulWidget {
  static const routeName = '/etims-invoices';
  const EtimsInvoicesScreen({super.key});

  @override
  State<EtimsInvoicesScreen> createState() => _EtimsInvoicesScreenState();
}

class _EtimsInvoicesScreenState extends State<EtimsInvoicesScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  String _taxMapping = 'EXEMPT';

  EtimsDevice? _device;
  List<EtimsInvoice> _invoices = [];
  bool _loading = true;
  bool _initializing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    final device = await provider.fetchDevice();
    List<EtimsInvoice> invoices = [];
    try {
      invoices = await provider.fetchInvoices();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _device = device;
      _invoices = invoices;
      _loading = false;
    });
  }

  Future<void> _initializeDevice() async {
    if (_pinController.text.trim().isEmpty ||
        _serialController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KRA PIN and device serial are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _initializing = true);
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    try {
      final result = await provider.initializeDevice(
        _pinController.text.trim(),
        _serialController.text.trim(),
        _taxMapping,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Done'),
          backgroundColor:
              result['status'] == true ? Colors.green : Colors.red,
        ),
      );
      setState(() {
        _initializing = false;
        _loading = true;
      });
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      setState(() => _initializing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Initialization failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _retry(EtimsInvoice invoice) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    final ok = await provider.retryInvoice(invoice.rentPaymentId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Sync re-queued' : 'Could not re-queue sync'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    if (ok) {
      setState(() => _loading = true);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: royalBlue,
        title: Text(
          'KRA eTIMS Invoices',
          style: GoogleFonts.hind(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: royalBlue))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDeviceCard(),
                  const SizedBox(height: 16),
                  Text(
                    'INVOICES',
                    style: GoogleFonts.hind(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_invoices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No eTIMS invoices yet.\nInvoices are generated automatically when tenants pay rent.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hind(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ..._invoices.map(_buildInvoiceTile),
                ],
              ),
            ),
    );
  }

  Widget _buildDeviceCard() {
    final device = _device;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.point_of_sale, color: royalBlue),
              const SizedBox(width: 8),
              Text(
                'OSCU Device',
                style: GoogleFonts.hind(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: royalBlue,
                ),
              ),
              const Spacer(),
              if (device != null) _statusChip(device.status),
            ],
          ),
          const SizedBox(height: 12),
          if (device != null && device.status == 'INITIALIZED') ...[
            Text('KRA PIN: ${device.kraPin ?? '-'}',
                style: GoogleFonts.hind(fontSize: 14)),
            Text('Serial: ${device.deviceSerial ?? '-'}',
                style: GoogleFonts.hind(fontSize: 14)),
            Text('SDC ID: ${device.sdcId ?? '-'}',
                style: GoogleFonts.hind(fontSize: 14)),
            Text('Tax mapping: ${device.taxMapping ?? '-'}',
                style: GoogleFonts.hind(fontSize: 14)),
          ] else ...[
            Text(
              'Register your KRA details to start issuing eTIMS receipts automatically.',
              style: GoogleFonts.hind(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pinController,
              decoration: _fieldDecoration('KRA PIN (e.g. A012345678Z)'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _serialController,
              decoration: _fieldDecoration('Device serial number'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _taxMapping,
              decoration: _fieldDecoration('Tax mapping'),
              items: const [
                DropdownMenuItem(
                    value: 'EXEMPT', child: Text('VAT Exempt (Code A)')),
                DropdownMenuItem(
                    value: 'RRI_10',
                    child: Text('Residential Rental Income 10%')),
              ],
              onChanged: (value) =>
                  setState(() => _taxMapping = value ?? 'EXEMPT'),
            ),
            const SizedBox(height: 12),
            Center(
              child: _initializing
                  ? const CircularProgressIndicator(color: royalBlue)
                  : ButtonLayout(
                      onClick: _initializeDevice,
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      text: Text(
                        'Initialize Device',
                        style: GoogleFonts.hind(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'INITIALIZED':
      case 'SYNCED':
        color = Colors.green;
        break;
      case 'FAILED':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.hind(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInvoiceTile(EtimsInvoice invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.tenantEmail ?? 'Tenant',
                  style: GoogleFonts.hind(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Rent ${invoice.month.toString().padLeft(2, '0')}/${invoice.year} · KES ${invoice.amount}',
                  style:
                      GoogleFonts.hind(fontSize: 13, color: Colors.grey[700]),
                ),
                if (invoice.kraInvoiceNumber != null)
                  Text(
                    'CU-INV: ${invoice.kraInvoiceNumber}',
                    style: GoogleFonts.hind(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          _statusChip(invoice.syncStatus),
          if (invoice.syncStatus == 'FAILED')
            IconButton(
              icon: const Icon(Icons.refresh, color: royalBlue),
              tooltip: 'Retry KRA sync',
              onPressed: () => _retry(invoice),
            ),
        ],
      ),
    );
  }
}
