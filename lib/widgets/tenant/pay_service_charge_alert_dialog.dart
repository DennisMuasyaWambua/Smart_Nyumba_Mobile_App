import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/utils/constants/colors.dart';
import 'package:smart_nyumba/utils/providers/payment_provider.dart';
import 'package:smart_nyumba/utils/providers/shared_preference_builder.dart';
import 'package:smart_nyumba/utils/providers/tenants_profile_provider.dart';
import 'package:smart_nyumba/screens/tenant/payment_webview_screen.dart';

/// Pay service charge for the current month or several months ahead.
class PayServiceChargeAlertDialog extends StatefulWidget {
  const PayServiceChargeAlertDialog({super.key});

  @override
  State<PayServiceChargeAlertDialog> createState() =>
      _PayServiceChargeAlertDialogState();
}

class _PayServiceChargeAlertDialogState
    extends State<PayServiceChargeAlertDialog> {
  static final RegExp _phoneRegex = RegExp(r'^254\d{9}$');

  final TextEditingController _phoneController = TextEditingController();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'KSh ', decimalDigits: 0);

  String? _serviceCharge;
  bool _loading = true;
  String? _loadError;

  bool _paying = false;
  String? _phoneError;
  String? _payError;
  int _monthsToPay = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final profile = await Provider.of<TenantsProfile>(context, listen: false)
          .getUserProfile(SharedPrefrenceBuilder.getUserToken!);
      if (!mounted) return;
      final charge = profile.propertyBlock?.serviceCharge?.toString();
      setState(() {
        _serviceCharge = charge;
        _loading = false;
        if (charge == null) {
          _loadError = 'Could not find your service charge. Please try again.';
        }
      });
    } catch (e) {
      log(e.toString(), name: 'PAY SERVICE DIALOG');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load your service charge. Please try again.';
      });
    }
  }

  List<Map<String, int>> _monthsForward(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) {
      final d = DateTime(now.year, now.month + i, 1);
      return {'month': d.month, 'year': d.year};
    });
  }

  double get _totalDue =>
      (double.tryParse(_serviceCharge ?? '') ?? 0) * _monthsToPay;

  Future<void> _pay() async {
    final phone = _phoneController.text.trim();
    if (!_phoneRegex.hasMatch(phone)) {
      setState(() => _phoneError = 'Enter your number in the format 254712345678');
      return;
    }
    setState(() {
      _phoneError = null;
      _payError = null;
      _paying = true;
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await Provider.of<Payments>(context, listen: false)
          .payMultiMonthService(phone, _monthsForward(_monthsToPay));
      if (!mounted) return;

      if (result.status == true && result.redirectUrl != null) {
        navigator.pop();
        navigator.pushNamed(
          PaymentWebViewScreen.routeName,
          arguments: {
            'paymentType': 'service',
            'redirectUrl': result.redirectUrl,
            'orderTrackingId': result.orderTrackingId,
            'email': SharedPrefrenceBuilder.getUserEmail,
          },
        ).then((success) {
          if (success == true) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Service charge payment completed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      } else {
        setState(() {
          _paying = false;
          _payError = result.message;
        });
      }
    } catch (e) {
      log(e.toString(), name: 'SERVICE PAYMENT ERROR');
      if (!mounted) return;
      setState(() {
        _paying = false;
        _payError = 'Payment could not be started. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pay Service Charge',
                      style: GoogleFonts.hind(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: royalBlue)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed:
                        _paying ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAmountHero(),
              const SizedBox(height: 16),
              _buildMonthStepper(),
              const SizedBox(height: 16),
              Text('M-Pesa phone number',
                  style: GoogleFonts.hind(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                enabled: !_paying,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.hind(fontSize: 15),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  hintText: '254712345678',
                  errorText: _phoneError,
                  errorMaxLines: 2,
                ),
                onChanged: (_) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
              ),
              if (_payError != null) ...[
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
                        child: Text(_payError!,
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
                  onPressed: (_paying || _loading || _serviceCharge == null)
                      ? null
                      : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: royalBlue,
                    disabledBackgroundColor: royalBlue.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _paying
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _serviceCharge == null
                              ? 'Pay'
                              : 'Pay ${_currencyFormat.format(_totalDue)}'
                                  '${_monthsToPay > 1 ? ' · ${_monthsToPay}mo' : ''}',
                          style: GoogleFonts.hind(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountHero() {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }
    if (_loadError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(_loadError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(
                    fontSize: 13, color: Colors.orange.shade800)),
            TextButton(
              onPressed: _load,
              child: Text('Retry',
                  style: GoogleFonts.hind(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }
    final parsed = double.tryParse(_serviceCharge ?? '');
    final formatted =
        parsed != null ? _currencyFormat.format(parsed) : 'KSh --';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          color: royalBlue.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text('Monthly service charge',
              style:
                  GoogleFonts.hind(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(formatted,
              style: GoogleFonts.hind(
                  fontSize: 28, fontWeight: FontWeight.w700, color: royalBlue)),
        ],
      ),
    );
  }

  Widget _buildMonthStepper() {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month + _monthsToPay - 1, 1);
    final range = _monthsToPay == 1
        ? DateFormat.yMMM().format(now)
        : '${DateFormat.MMM().format(now)} – ${DateFormat.yMMM().format(last)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Months to pay',
            style: GoogleFonts.hind(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        Row(
          children: [
            _stepBtn(Icons.remove, _monthsToPay > 1 && !_paying,
                () => setState(() => _monthsToPay--)),
            Expanded(
              child: Column(
                children: [
                  Text('$_monthsToPay',
                      style: GoogleFonts.hind(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: royalBlue)),
                  Text(range,
                      style: GoogleFonts.hind(
                          fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            _stepBtn(Icons.add, _monthsToPay < 12 && !_paying,
                () => setState(() => _monthsToPay++)),
          ],
        ),
      ],
    );
  }

  Widget _stepBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color:
              enabled ? royalBlue.withValues(alpha: 0.08) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: enabled ? royalBlue : Colors.grey.shade400, size: 20),
      ),
    );
  }
}
