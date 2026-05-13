import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:smart_nyumba/utils/services/deep_link_service.dart';

/// Handles payment redirect from Pesapal
///
/// Initialize this in your main app widget to handle payment completion redirects
class PaymentRedirectHandler {
  static void initialize(BuildContext context) {
    DeepLinkService().initialize(
      onPaymentComplete: (paymentType) {
        _handlePaymentComplete(context, paymentType);
      },
    );
  }

  static void _handlePaymentComplete(BuildContext context, String paymentType) {
    // Show success alert based on payment type
    String title = 'Payment Received';
    String message = '';

    switch (paymentType) {
      case 'activation':
        title = 'Account Activation';
        message = 'Your landlord account activation payment is being processed. '
            'You will be notified once your account is activated.';
        break;
      case 'service':
        title = 'Service Charge Payment';
        message = 'Your service charge payment is being processed. '
            'Please check your transactions for confirmation.';
        break;
      case 'rent':
        title = 'Rent Payment';
        message = 'Your rent payment is being processed. '
            'Please check your transactions for confirmation.';
        break;
      default:
        title = 'Payment Received';
        message = 'Your payment is being processed.';
    }

    // Show success dialog
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: title,
      text: message,
      confirmBtnText: 'OK',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        _navigateAfterPayment(context, paymentType);
      },
    );
  }

  static void _navigateAfterPayment(BuildContext context, String paymentType) {
    // Navigate based on payment type
    switch (paymentType) {
      case 'activation':
        // For activation, navigate to login screen
        // The backend will activate the account via IPN callback
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        break;
      case 'service':
      case 'rent':
        // For service and rent, navigate to dashboard/transactions
        // User can check their payment status there
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/tenant-dashboard',
          (route) => false,
        );
        break;
      default:
        // Default: go to home
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
    }
  }
}
