import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/constants.dart';
import '../../utils/providers/internet_checker.dart';
import '../../utils/providers/payment_provider.dart';
import '../../widgets/button_layout.dart';
import '../landlord/landlord_home.dart';

enum PaymentState { initial, loading, webview, polling, success, failed }

class ActivationPaymentScreen extends StatefulWidget {
  static const routeName = '/activation-payment';
  const ActivationPaymentScreen({super.key});

  @override
  State<ActivationPaymentScreen> createState() =>
      _ActivationPaymentScreenState();
}

class _ActivationPaymentScreenState extends State<ActivationPaymentScreen> {
  late TextEditingController _phoneController;
  PaymentState _paymentState = PaymentState.initial;
  String _errorMessage = '';
  Timer? _pollTimer;
  int _pollCount = 0;
  static const int _maxPollAttempts = 10; // 10 attempts * 3 seconds = 30 seconds

  String? _redirectUrl;
  String? _orderTrackingId;
  late WebViewController _webViewController;
  bool _isWebViewReady = false;

  @override
  void initState() {
    _phoneController = TextEditingController();
    _initializeWebView();
    super.initState();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log('Page started loading: $url', name: 'WEBVIEW');
          },
          onPageFinished: (String url) {
            log('Page finished loading: $url', name: 'WEBVIEW');

            // Check if payment completed by monitoring URL patterns
            if (url.contains('payment-complete') ||
                url.contains('success') ||
                url.contains('completed')) {
              log('Payment may be complete, starting status check', name: 'WEBVIEW');
              _startPollingAfterPayment();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            log('Navigation request: ${request.url}', name: 'WEBVIEW');
            return NavigationDecision.navigate;
          },
        ),
      );

    setState(() {
      _isWebViewReady = true;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _initiatePayment(Map<String, dynamic> args) {
    final email = args['email'] as String? ?? '';
    final firstName = args['firstName'] as String? ?? '';
    final lastName = args['lastName'] as String? ?? '';

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate phone number format
    final phone = _phoneController.text.trim();
    if (phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check internet connection
    if (!Provider.of<InternetChecker>(context, listen: false)
        .isInternetActive) {
      Provider.of<InternetChecker>(context, listen: false)
          .showInternetConnectionDialog(context);
      return;
    }

    setState(() {
      _paymentState = PaymentState.loading;
      _errorMessage = '';
    });

    // Initiate Pesapal payment
    var paymentProvider = Provider.of<Payments>(context, listen: false);
    paymentProvider
        .initiateActivationPaymentPesapal(
          email: email,
          mobileNumber: phone,
          firstName: firstName,
          lastName: lastName,
        )
        .then((response) {
      log(response.toJson().toString(), name: "PESAPAL PAYMENT RESPONSE");

      if (response.status == true && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _redirectUrl = data['redirect_url'] as String?;
          _orderTrackingId = data['order_tracking_id'] as String?;

          if (_redirectUrl != null && _orderTrackingId != null) {
            _paymentState = PaymentState.webview;
            // Load the Pesapal checkout page
            _webViewController.loadRequest(Uri.parse(_redirectUrl!));
          } else {
            _paymentState = PaymentState.failed;
            _errorMessage = 'Failed to get payment URL';
          }
        });
      } else {
        setState(() {
          _paymentState = PaymentState.failed;
          _errorMessage = response.message ?? 'Payment initiation failed';
        });
      }
    }).catchError((error) {
      log(error.toString(), name: "PESAPAL PAYMENT ERROR");
      setState(() {
        _paymentState = PaymentState.failed;
        _errorMessage = 'Network error. Please try again.';
      });
    });
  }

  void _startPollingAfterPayment() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] as String? ?? '';

    if (_paymentState == PaymentState.webview) {
      setState(() {
        _paymentState = PaymentState.polling;
        _pollCount = 0;
      });
      _startPolling(email);
    }
  }

  void _startPolling(String email) {
    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollCount++;

      if (_pollCount > _maxPollAttempts) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _paymentState = PaymentState.failed;
            _errorMessage =
                'Payment verification timeout. Please check back later or contact support.';
          });
        }
        return;
      }

      var paymentProvider = Provider.of<Payments>(context, listen: false);
      paymentProvider.checkActivationPaymentStatus(email).then((status) {
        log("Activation status: $status", name: "ACTIVATION STATUS CHECK");

        if (status == 1) {
          // Payment completed
          timer.cancel();
          if (mounted) {
            setState(() {
              _paymentState = PaymentState.success;
            });

            // Show success message and navigate to dashboard
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(
                  LandlordHome.routeName,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account activated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            });
          }
        } else if (status == 2) {
          // Payment failed
          timer.cancel();
          if (mounted) {
            setState(() {
              _paymentState = PaymentState.failed;
              _errorMessage = 'Payment failed. Please try again.';
            });
          }
        }
        // status == 0 means still pending, continue polling
      }).catchError((error) {
        log(error.toString(), name: "ACTIVATION STATUS CHECK ERROR");
        // Don't cancel timer on check errors, might be temporary
      });
    });
  }

  void _retryPayment() {
    setState(() {
      _paymentState = PaymentState.initial;
      _errorMessage = '';
      _pollCount = 0;
      _redirectUrl = null;
      _orderTrackingId = null;
    });
    _pollTimer?.cancel();
    _phoneController.clear();
  }

  void _cancelPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Payment?',
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to cancel this payment? You will need to pay the activation fee to access your account.',
          style: GoogleFonts.hind(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: GoogleFonts.hind()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _retryPayment();
            },
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.hind(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] as String? ?? '';
    final firstName = args?['firstName'] as String? ?? 'Landlord';

    // If in webview state, show only the webview
    if (_paymentState == PaymentState.webview) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Complete Payment',
            style: GoogleFonts.hind(fontWeight: FontWeight.w600),
          ),
          backgroundColor: royalBlue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancelPayment,
          ),
        ),
        body: _isWebViewReady
            ? WebViewWidget(controller: _webViewController)
            : const Center(child: CircularProgressIndicator()),
      );
    }

    // Show regular payment screen
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset(Constants.SMART_NYUMBA_BLACK),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Activate Your Account',
                style: GoogleFonts.hind(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: royalBlue,
                ),
              ),

              const SizedBox(height: 10),

              // Welcome message
              Text(
                'Welcome $firstName!',
                style: GoogleFonts.hind(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Complete activation to access your landlord dashboard',
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 30),

              // Registration summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Summary',
                      style: GoogleFonts.hind(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Email:',
                          style: GoogleFonts.hind(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Flexible(
                          child: Text(
                            email,
                            style: GoogleFonts.hind(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Role:',
                          style: GoogleFonts.hind(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Landlord',
                          style: GoogleFonts.hind(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Activation fee card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(65, 105, 225, 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color.fromRGBO(65, 105, 225, 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Activation Fee',
                      style: GoogleFonts.hind(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: royalBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KES ${Constants.LANDLORD_ACTIVATION_FEE.toStringAsFixed(0)}',
                      style: GoogleFonts.hind(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: royalBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Payment status widget
              if (_paymentState != PaymentState.initial)
                _buildPaymentStatusWidget(),

              const SizedBox(height: 20),

              // Phone input (hide when processing/polling/success)
              if (_paymentState == PaymentState.initial ||
                  _paymentState == PaymentState.failed) ...[
                Text(
                  'Enter Phone Number:',
                  style: GoogleFonts.hind(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: royalBlue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    hintText: '254712345678 or 0712345678',
                    prefixIcon: const Icon(Icons.phone_android, color: royalBlue),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You can pay via M-Pesa or Card',
                  style: GoogleFonts.hind(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 30),

              // Action button
              if (_paymentState == PaymentState.initial)
                ButtonLayout(
                  onClick: () => _initiatePayment(args ?? {}),
                  text: Text(
                    'Proceed to Payment',
                    style: GoogleFonts.hind(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 18,
                  ),
                )
              else if (_paymentState == PaymentState.failed)
                ButtonLayout(
                  onClick: _retryPayment,
                  text: Text(
                    'Try Again',
                    style: GoogleFonts.hind(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 16,
                  ),
                ),

              const SizedBox(height: 20),

              // Payment secured text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Payment secured by Pesapal',
                    style: GoogleFonts.hind(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusWidget() {
    switch (_paymentState) {
      case PaymentState.loading:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(royalBlue),
              ),
              const SizedBox(height: 16),
              Text(
                'Preparing Payment...',
                style: GoogleFonts.hind(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: royalBlue,
                ),
              ),
            ],
          ),
        );

      case PaymentState.polling:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 16),
              Text(
                'Verifying Payment',
                style: GoogleFonts.hind(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we confirm your payment...',
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(
                  fontSize: 14,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 16),
              const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 12),
              Text(
                'Checking... (Attempt $_pollCount/$_maxPollAttempts)',
                style: GoogleFonts.hind(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

      case PaymentState.success:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: GoogleFonts.hind(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your account has been activated',
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(
                  fontSize: 14,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Redirecting to dashboard...',
                style: GoogleFonts.hind(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );

      case PaymentState.failed:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Failed',
                style: GoogleFonts.hind(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(
                  fontSize: 14,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
