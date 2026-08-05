import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/constants/colors.dart';
import '../../utils/providers/payment_provider.dart';
import '../../utils/providers/subscription_provider.dart';

enum PaymentState { loading, webview, polling, success, pending, failed }

/// Generic payment WebView screen for payments (rent, service charge and
/// landlord SaaS subscriptions)
///
/// Pass the following arguments via Navigator:
/// - paymentType: 'rent', 'service' or 'subscription'
/// - redirectUrl: gateway payment URL (Pesapal or iPay)
/// - orderTrackingId: order tracking/order id from the gateway
/// - email: User email (for polling payment status)
class PaymentWebViewScreen extends StatefulWidget {
  static const routeName = '/payment-webview';
  const PaymentWebViewScreen({super.key});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  PaymentState _paymentState = PaymentState.loading;
  String _errorMessage = '';
  Timer? _pollTimer;
  int _pollCount = 0;
  static const int _maxPollAttempts = 10; // 10 attempts * 3 seconds = 30 seconds

  late WebViewController _webViewController;
  bool _isWebViewReady = false;

  String? _paymentType;
  String? _redirectUrl;
  String? _orderTrackingId;

  @override
  void initState() {
    _initializeWebView();
    super.initState();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log('Page started loading: $url', name: 'PAYMENT_WEBVIEW');
          },
          onPageFinished: (String url) {
            log('Page finished loading: $url', name: 'PAYMENT_WEBVIEW');

            // Check if payment completed by monitoring URL patterns
            // (iPay redirects back to our /subscriptions/ipay/callback/ URL)
            if (url.contains('payment-complete') ||
                url.contains('success') ||
                url.contains('completed') ||
                url.contains('ipay/callback')) {
              log('Payment may be complete, starting status check',
                  name: 'PAYMENT_WEBVIEW');
              _startPollingAfterPayment();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            log('Navigation request: ${request.url}', name: 'PAYMENT_WEBVIEW');

            // Pesapal redirects back to our deep link (smartnyumba://...) once
            // the shopper finishes checkout. A WebView can't load a custom
            // scheme, so intercept it here to start status polling instead of
            // letting the navigation fail.
            if (request.url.startsWith('smartnyumba://') ||
                request.url.contains('payment-complete')) {
              log('Payment callback detected, starting status check',
                  name: 'PAYMENT_WEBVIEW');
              _startPollingAfterPayment();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    setState(() {
      _isWebViewReady = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments passed via Navigator
    if (_redirectUrl == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _paymentType = args['paymentType'] as String?;
          _redirectUrl = args['redirectUrl'] as String?;
          _orderTrackingId = args['orderTrackingId'] as String?;

          if (_redirectUrl != null) {
            _paymentState = PaymentState.webview;
            _webViewController.loadRequest(Uri.parse(_redirectUrl!));
          } else {
            _paymentState = PaymentState.failed;
            _errorMessage = 'No payment URL provided';
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPollingAfterPayment() {
    setState(() {
      _paymentState = PaymentState.polling;
    });

    _pollCount = 0;
    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    _pollCount++;
    log('Checking payment status (attempt $_pollCount/$_maxPollAttempts)',
        name: 'PAYMENT_CHECK');

    try {
      int? status;

      // Every status check needs the gateway order tracking id to look up the
      // transaction. Without it we can't verify, so surface a failure instead
      // of hanging.
      if (_orderTrackingId == null || _orderTrackingId!.isEmpty) {
        log('Missing orderTrackingId, cannot verify payment',
            name: 'PAYMENT_CHECK');
        _pollTimer?.cancel();
        setState(() {
          _paymentState = PaymentState.pending;
        });
        return;
      }

      // Check payment status based on payment type
      if (_paymentType == 'subscription') {
        status = await Provider.of<SubscriptionProvider>(context, listen: false)
            .checkSubscriptionPaymentStatus(_orderTrackingId!);
      } else if (_paymentType == 'rent') {
        status = await Provider.of<Payments>(context, listen: false)
            .checkRentPaymentStatus(_orderTrackingId!);
      } else {
        status = await Provider.of<Payments>(context, listen: false)
            .checkPaymentStatus(_orderTrackingId!);
      }

      log('Payment status: $status', name: 'PAYMENT_CHECK');

      if (status == 1) {
        // Payment successful (1 = completed, 0 = pending)
        _pollTimer?.cancel();
        setState(() {
          _paymentState = PaymentState.success;
        });
      } else if (_pollCount >= _maxPollAttempts) {
        // Not confirmed yet — the payment may still be processing, so show
        // a "pending" state rather than a failure.
        _pollTimer?.cancel();
        setState(() {
          _paymentState = PaymentState.pending;
        });
      } else {
        setState(() {}); // refresh the progress indicator
      }
    } catch (e) {
      log('Error checking payment status: ${e.toString()}',
          name: 'PAYMENT_CHECK');

      if (_pollCount >= _maxPollAttempts) {
        _pollTimer?.cancel();
        setState(() {
          _paymentState = PaymentState.pending;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back navigation during polling without confirmation
      canPop: _paymentState != PaymentState.polling,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Payment?'),
            content: const Text(
                'Payment is being verified. Are you sure you want to cancel?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        if (shouldPop != true || !context.mounted) return;
        _pollTimer?.cancel();
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: royalBlue,
          title: Text(
            _paymentType == 'subscription'
                ? 'Pay Subscription'
                : _paymentType == 'rent'
                    ? 'Pay Rent'
                    : 'Pay Service Charge',
            style: GoogleFonts.hind(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_paymentState) {
      case PaymentState.loading:
        return const Center(
          child: CircularProgressIndicator(color: royalBlue),
        );

      case PaymentState.webview:
        if (!_isWebViewReady) {
          return const Center(
            child: CircularProgressIndicator(color: royalBlue),
          );
        }
        return WebViewWidget(controller: _webViewController);

      case PaymentState.polling:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: royalBlue),
                const SizedBox(height: 32),
                Text(
                  'Confirming your payment',
                  style: GoogleFonts.hind(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This usually takes a few seconds. Please keep this screen open.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _pollCount / _maxPollAttempts,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(royalBlue),
                  ),
                ),
              ],
            ),
          ),
        );

      case PaymentState.pending:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_top,
                  color: statusAmber,
                  size: 80,
                ),
                const SizedBox(height: 32),
                Text(
                  'Payment still processing',
                  style: GoogleFonts.hind(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "We haven't received confirmation yet. If you completed the "
                  'payment, it will reflect in your transactions shortly — '
                  "it's safe to leave this screen.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _startPollingAfterPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: royalBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    'Check Again',
                    style: GoogleFonts.hind(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Done',
                    style: GoogleFonts.hind(
                      color: royalBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case PaymentState.success:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 32),
                Text(
                  'Payment Successful!',
                  style: GoogleFonts.hind(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your ${_paymentType == 'subscription' ? 'subscription' : _paymentType == 'rent' ? 'rent' : 'service charge'} payment has been received.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: royalBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.hind(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case PaymentState.failed:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 32),
                Text(
                  'Payment Failed',
                  style: GoogleFonts.hind(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage.isEmpty
                      ? 'Unable to process payment. Please try again.'
                      : _errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: royalBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.hind(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
