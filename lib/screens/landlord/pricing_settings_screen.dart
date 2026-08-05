import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/colors.dart';
import '../../utils/models/subscription.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../utils/providers/subscription_provider.dart';
import '../../widgets/button_layout.dart';
import '../tenant/payment_webview_screen.dart';

class PricingSettingsScreen extends StatefulWidget {
  static const routeName = '/pricing-settings';
  const PricingSettingsScreen({super.key});

  @override
  State<PricingSettingsScreen> createState() => _PricingSettingsScreenState();
}

class _PricingSettingsScreenState extends State<PricingSettingsScreen> {
  final TextEditingController _phoneController = TextEditingController();
  List<SubscriptionPlan> _plans = [];
  MySubscription? _subscription;
  bool _loading = true;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    try {
      final results = await Future.wait([
        provider.fetchPlans(),
        provider.fetchMySubscription(),
      ]);
      if (!mounted) return;
      setState(() {
        _plans = results[0] as List<SubscriptionPlan>;
        _subscription = results[1] as MySubscription?;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load plans: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _payWithIpay(SubscriptionPlan plan) async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your M-Pesa phone number first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _paying = true);
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    try {
      final init = await provider.initiatePayment(
          plan.tier, _phoneController.text.trim());

      if (!mounted) return;
      setState(() => _paying = false);

      if (init.status != true || init.paymentUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(init.message.isEmpty
                ? 'Could not initiate payment'
                : init.message),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await Navigator.pushNamed(
        context,
        PaymentWebViewScreen.routeName,
        arguments: {
          'paymentType': 'subscription',
          'redirectUrl': init.paymentUrl,
          'orderTrackingId': init.orderId,
          'email': SharedPrefrenceBuilder.getUserEmail,
        },
      );

      if (!mounted) return;
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plan.name} subscription activated!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _loading = true);
        await _loadData();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: royalBlue,
        title: Text(
          'Pricing & Subscription',
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
                  _buildCurrentPlanBanner(),
                  const SizedBox(height: 16),
                  _buildPhoneField(),
                  const SizedBox(height: 16),
                  ..._plans.map((plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPlanCard(plan),
                      )),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentPlanBanner() {
    final sub = _subscription;
    final active = sub?.isActive ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: active ? Colors.green.shade300 : Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.verified : Icons.info_outline,
            color: active ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active
                      ? 'Current plan: ${sub!.tierLevel}'
                      : 'No active subscription',
                  style: GoogleFonts.hind(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: royalBlue,
                  ),
                ),
                if (active && sub!.expiryDate != null)
                  Text(
                    'Renews / expires ${_formatDate(sub.expiryDate!)}',
                    style: GoogleFonts.hind(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                if (!active)
                  Text(
                    'Choose a plan below to activate your account features.',
                    style: GoogleFonts.hind(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso.split('T').first;
    }
  }

  Widget _buildPhoneField() {
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
              const Icon(Icons.phone_android, size: 18, color: royalBlue),
              const SizedBox(width: 8),
              Text(
                'Payment details',
                style: GoogleFonts.hind(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: royalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'The M-Pesa number to charge when you pick a plan below.',
            style: GoogleFonts.hind(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            cursorColor: Colors.black,
            style: GoogleFonts.hind(fontSize: 15),
            decoration: InputDecoration(
              hintText: '254XXXXXXXXX',
              prefixIcon: const Icon(Icons.sim_card_outlined, size: 20),
              filled: true,
              fillColor: Colors.grey.shade50,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: royalBlue),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isPremiumPlan = plan.tier == 'PREMIUM';
    final isCurrent =
        (_subscription?.isActive ?? false) && _subscription?.tierLevel == plan.tier;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremiumPlan ? darkGold : Colors.grey.shade300,
          width: isPremiumPlan ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isPremiumPlan ? Icons.workspace_premium : Icons.apartment,
                    color: isPremiumPlan ? darkGold : royalBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    plan.name,
                    style: GoogleFonts.hind(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: royalBlue,
                    ),
                  ),
                ],
              ),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Current plan',
                    style: GoogleFonts.hind(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KES ${plan.price}',
                style: GoogleFonts.hind(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: royalBlue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  '/month',
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Up to ${plan.unitLimit} units',
            style: GoogleFonts.hind(fontSize: 13, color: Colors.grey[600]),
          ),
          const Divider(height: 24),
          ...plan.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: GoogleFonts.hind(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Center(
            child: _paying
                ? const CircularProgressIndicator(color: royalBlue)
                : ButtonLayout(
                    onClick: () => _payWithIpay(plan),
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    text: Text(
                      isCurrent ? 'Renew with iPay' : 'Pay with iPay',
                      style: GoogleFonts.hind(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
