import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/constants/colors.dart';
import '../../utils/providers/payment_provider.dart';

enum PaymentState { loading, webview, polling, success, failed }

/// Generic payment WebView screen for tenant payments (rent and service charge)
///
/// Pass the following arguments via Navigator:
/// - paymentType: 'rent' or 'service'
/// - redirectUrl: Pesapal payment URL
/// - orderTrackingId: Order tracking ID from Pesapal
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
  String? _email;

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
            if (url.contains('payment-complete') ||
                url.contains('success') ||
                url.contains('completed')) {
              log('Payment may be complete, starting status check',
                  name: 'PAYMENT_WEBVIEW');
              _startPollingAfterPayment();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            log('Navigation request: ${request.url}', name: 'PAYMENT_WEBVIEW');
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
          _email = args['email'] as String?;

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
      var paymentProvider = Provider.of<Payments>(context, listen: false);
      int? status;

      // Check payment status based on payment type
      if (_paymentType == 'rent') {
        status = await paymentProvider.checkRentPaymentStatus();
      } else {
        status = await paymentProvider.checkPaymentStatus();
      }

      log('Payment status: $status', name: 'PAYMENT_CHECK');

      if (status == 1) {
        // Payment successful (1 = completed, 0 = pending)
        _pollTimer?.cancel();
        setState(() {
          _paymentState = PaymentState.success;
        });

        // Auto navigate back after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true); // Return success
          }
        });
      } else if (_pollCount >= _maxPollAttempts) {
        // Only timeout if status is not successful after max attempts
        _pollTimer?.cancel();
        setState(() {
          _paymentState = PaymentState.failed;
          _errorMessage =
              'Payment verification timeout. Please check your transactions.';
        });
      }
    } catch (e) {
      log('Error checking payment status: ${e.toString()}',
          name: 'PAYMENT_CHECK');

      if (_pollCount >= _maxPollAttempts) {
        _pollTimer?.cancel();
        setState(() {
          _paymentState = PaymentState.failed;
          _errorMessage = 'Unable to verify payment. Please check your transactions.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation during polling
        if (_paymentState == PaymentState.polling) {
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
                  onPressed: () {
                    _pollTimer?.cancel();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: royalBlue,
          title: Text(
            _paymentType == 'rent' ? 'Pay Rent' : 'Pay Service Charge',
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
                  'Verifying Payment',
                  style: GoogleFonts.hind(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please wait while we confirm your payment...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    color: Colors.grey[600],
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
                  'Your ${_paymentType == 'rent' ? 'rent' : 'service charge'} payment has been received.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    color: Colors.grey[600],
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
