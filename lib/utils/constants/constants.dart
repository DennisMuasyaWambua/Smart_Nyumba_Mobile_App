import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  //regular expressions
  static RegExp emailRegex = RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$");
  static RegExp passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$");
  //Authentication constants
  static const String email = "email";
  static const String firstName = "first name";
  static const String lastName = "last name";
  static const String idNumber = "id number";
  static const String blockNumber = "block number";
  static const String houseNumber = "house number";
  static const String mobileNumber = "mobile number";
  static const String password = "password";
  static const String confirmPassword = "confirm password";
  static const String login = "Login";
  static const String register = "Register";
  static const String joinMessage = "Joining us today?";

  //Util constants
  static const String dashboard = "Dashboard";
  static const String addNewRole = "Add new role";
  static const String addNewRoleDescription =
      "Create a new role and assign an elected tenant";
  static const String serviceChargePayments = "All service chage payments";
  static const String payment = "Make Payment";
  static const String welcomeMsg = "User name";
  static const String paymentHistory = "Payment Statement";
  static const String serviceChargeBalance = "Service Charge";
  static const String payServiceCharge = "Pay Service Charge";
  static const String service = "Request for Repairs";
  static const String marketPlace = "Marketplace";
  static const String noService = "You are not subscribed to any service";
  static const String serviceCharge = "Service Charge";
  static const String OtpVerification = "OTP VERIFICATION";
  static const String didntGetCode = "Didn't get code? Resend Code";
  static const String createRole = "Create role";

  //colors
  static const buttonColor = Color(0xffbc9f6d);
  static const serviceColor = Color(0xfff68070);
  static const paymentColor = Color(0xff4cd964);
  static const servicesColor = Color(0xff567df4);
  static const purple = Color(0xff6246ea);
  static const themePurple = Color(0xff22215B);

  // URL constants
// https://smartnyumbabackup-production-b9a7.up.railway.app/
// https://api.smartnyumba.com
// hetzner url: https://api.smartnyumba.tech/
  // The API root can be overridden via API_BASE_URL in .env (e.g. a local
  // backend at http://10.0.2.2:8001/apps/api/v1 when testing on an emulator).
  static const String _defaultApiRoot =
      "https://api.smartnyumba.tech/apps/api/v1";

  static String get BASE_API_URL {
    if (dotenv.isInitialized && (dotenv.env['API_BASE_URL']?.isNotEmpty ?? false)) {
      return dotenv.env['API_BASE_URL']!;
    }
    return _defaultApiRoot;
  }

  //authentication related constants
  static String get AUTHENTICATION_BASE_URL => "$BASE_API_URL/auth";
  static String get LOGOUT_URL => "$AUTHENTICATION_BASE_URL/user-logout/";

  static String get ADMIN_LOGOUT_URL =>
      "$AUTHENTICATION_BASE_URL/admin-logout/";
  static String get LOGIN_URL => "$AUTHENTICATION_BASE_URL/user-login/";
  static String get REGISTER_URL => "$AUTHENTICATION_BASE_URL/user-register/";
  static String get VERIFY_OTP =>
      "$AUTHENTICATION_BASE_URL/user-register-verification/";
  static String get REGISTER_RESEND_OTP =>
      "$AUTHENTICATION_BASE_URL/resend-otp/";
  static String get RESEND_OTP => "$AUTHENTICATION_BASE_URL/user-resend-otp/";

  // Forgot-password flow (universal user accounts: tenant/landlord/etc.)
  static String get USER_FORGOT_PASSWORD =>
      "$AUTHENTICATION_BASE_URL/user-forgot-password/";
  static String get USER_VERIFY_RESET_OTP =>
      "$AUTHENTICATION_BASE_URL/user-verify-change-password/";
  static String get USER_NEW_PASSWORD =>
      "$AUTHENTICATION_BASE_URL/user-new-password/";
  static String get USER_PROFILE => "$AUTHENTICATION_BASE_URL/user-profile/";

  // Profile picture (R2) endpoints
  static String get PROFILE_IMAGE_PRESIGN_UPLOAD =>
      "$AUTHENTICATION_BASE_URL/profile-image/presign-upload/";
  static String get PROFILE_IMAGE =>
      "$AUTHENTICATION_BASE_URL/profile-image/";
  static String get ADMIN_PROFILE => "$AUTHENTICATION_BASE_URL/admin-profile/";

  // Landlord activation payment endpoints
  static String get INITIATE_ACTIVATION_PAYMENT =>
      "$AUTHENTICATION_BASE_URL/initiate-activation-payment/";
  static String get CHECK_ACTIVATION_STATUS =>
      "$AUTHENTICATION_BASE_URL/check-activation-status/";
  static String get ACTIVATION_MPESA_CALLBACK =>
      "$AUTHENTICATION_BASE_URL/activation-mpesa-callback/";
  static const double LANDLORD_ACTIVATION_FEE = 500.00;

  static String get TENANT_LOGOUT_URL =>
      "$AUTHENTICATION_BASE_URL/user-logout/";

  //LANDLORD related constants
  static String get LANDLORD_BASE_URL => "$BASE_API_URL/block-landlord";
  static String get LANDLORD_LOGIN_URL =>
      "$AUTHENTICATION_BASE_URL/landlord-login/";
  static String get LANDLORD_LOGOUT_URL =>
      "$LANDLORD_BASE_URL/block-landlord-logout/";
  static String get LANDLORD_PROFILE_URL =>
      "$LANDLORD_BASE_URL/block-landlord-profile/";
  static String get ADD_HOUSE_URL =>
      "$BASE_API_URL/properties/add-block-houses/";

  // Landlord property management
  static String get LANDLORD_ADD_PROPERTY_URL =>
      "$BASE_API_URL/properties/landlord-add-property/";
  static String get LANDLORD_PROPERTIES_URL =>
      "$BASE_API_URL/properties/landlord-properties/";
  static String get AVAILABLE_HOUSES_URL =>
      "$BASE_API_URL/properties/available-houses/";

  static String get LANDLORD_FORGOT_PASSWORD =>
      "$LANDLORD_BASE_URL/block-landlord-forgot-password/";
  static String get LANDLORD_VERIFY_CHANGE_PASSWORD =>
      "$LANDLORD_BASE_URL/block-landlord-verify-change-password/";
  static String get LANDLORD_RESEND_OTP =>
      "$LANDLORD_BASE_URL/block-landlord-resend-otp/";
  static String get LANDLORD_NEW_PASSWORD =>
      "$LANDLORD_BASE_URL/block-landlord-new-password/";

  // Subordinate management endpoints
  static String get LANDLORD_CREATE_SUBORDINATE =>
      "$AUTHENTICATION_BASE_URL/landlord-create-subordinate/";

  // Tenant onboarding endpoints
  static String get LANDLORD_ONBOARD_TENANT =>
      "$AUTHENTICATION_BASE_URL/landlord-onboard-tenant/";

  // Self-service settings endpoints
  static String get UPDATE_MY_PROFILE =>
      "$AUTHENTICATION_BASE_URL/update-my-profile/";
  static String get CHANGE_MY_PASSWORD =>
      "$AUTHENTICATION_BASE_URL/change-my-password/";

  // Financial dashboard endpoint
  static String get LANDLORD_FINANCIAL_SUMMARY =>
      "$LANDLORD_BASE_URL/financial-summary/";

  // Landlord transactions endpoint
  static String get LANDLORD_TRANSACTIONS =>
      "$LANDLORD_BASE_URL/landlord-transactions/";

  // Landlord defaulters endpoint
  static String get LANDLORD_DEFAULTERS =>
      "$LANDLORD_BASE_URL/landlord-defaulters/";
  static String get SET_PROPERTY_PENALTY =>
      "$LANDLORD_BASE_URL/set-property-penalty/";

  //CARETAKER related constants
  static String get CARETAKER_BASE_URL => "$BASE_API_URL/caretaker";
  static String get CARETAKER_LOGIN_URL =>
      "$CARETAKER_BASE_URL/caretaker-login/";
  static String get CARETAKER_LOGOUT_URL =>
      "$CARETAKER_BASE_URL/caretaker-logout/";
  static String get CARETAKER_PROFILE_URL =>
      "$CARETAKER_BASE_URL/caretaker-profile/";
  static String get CARETAKER_FORGOT_PASSWORD =>
      "$CARETAKER_BASE_URL/caretaker-forgot-password/";
  static String get CARETAKER_VERIFY_CHANGE_PASSWORD =>
      "$CARETAKER_BASE_URL/caretaker-verify-change-password/";
  static String get CARETAKER_RESEND_OTP =>
      "$CARETAKER_BASE_URL/caretaker-resend-otp/";
  static String get CARETAKER_NEW_PASSWORD =>
      "$CARETAKER_BASE_URL/caretaker-new-password/";

  //ACCOUNTS STAFF related constants
  static String get ACCOUNTS_BASE_URL => "$BASE_API_URL/staff-accounts";
  static String get ACCOUNTS_LOGIN_URL => "$ACCOUNTS_BASE_URL/accounts-login/";
  static String get ACCOUNTS_LOGOUT_URL =>
      "$ACCOUNTS_BASE_URL/accounts-logout/";
  static String get ACCOUNTS_PROFILE_URL =>
      "$ACCOUNTS_BASE_URL/accounts-profile/";
  static String get ACCOUNTS_FORGOT_PASSWORD =>
      "$ACCOUNTS_BASE_URL/accounts-forgot-password/";
  static String get ACCOUNTS_VERIFY_CHANGE_PASSWORD =>
      "$ACCOUNTS_BASE_URL/accounts-verify-change-password/";
  static String get ACCOUNTS_RESEND_OTP =>
      "$ACCOUNTS_BASE_URL/accounts-resend-otp/";
  static String get ACCOUNTS_NEW_PASSWORD =>
      "$ACCOUNTS_BASE_URL/accounts-new-password/";

  //PAYMENT related constants
  static String get PAYMENT_BASE_URL => "$BASE_API_URL/tenant-services";

  static String get PAY_SERVICE => "$PAYMENT_BASE_URL/pay-service/";
  static String get PAY_RENT => "$PAYMENT_BASE_URL/pay-rent/";
  static String get MPESA_CALLBACK => "$PAYMENT_BASE_URL/mpesa-callback";
  static String get MPESA_RENT_CALLBACK =>
      "$PAYMENT_BASE_URL/mpesa-rent-callback";
  static String get ALL_TRANSACTIONS => "$PAYMENT_BASE_URL/all-transactions/";
  static String get CHECK_PAYMENT_COMPLETION =>
      "$PAYMENT_BASE_URL/check-subscription-status/";
  // Authoritative status endpoint (CheckPaymentStatusAPIView): live-queries
  // Pesapal by order_tracking_id + transaction_type, so it doesn't depend on
  // the IPN webhook having already arrived.
  static String get CHECK_PAYMENT_STATUS =>
      "$PAYMENT_BASE_URL/check-payment-status/";
  static String get CHECK_RENT_PAYMENT_COMPLETION =>
      "$PAYMENT_BASE_URL/check-rent-payment-status/";
  static String get MONTHLY_RENT_SUMMARY =>
      "$PAYMENT_BASE_URL/monthly-rent-summary/";
  static String get MONTHLY_SERVICE_SUMMARY =>
      "$PAYMENT_BASE_URL/monthly-service-summary/";
  static String get PAY_MULTI_MONTH_RENT =>
      "$PAYMENT_BASE_URL/pay-multi-month-rent/";
  static String get PAY_MULTI_MONTH_SERVICE =>
      "$PAYMENT_BASE_URL/pay-multi-month-service/";
  static String get RECEIPT_PRESIGN_UPLOAD =>
      "$PAYMENT_BASE_URL/receipts/presign-upload/";
  static String get RECEIPT_PRESIGN_DOWNLOAD =>
      "$PAYMENT_BASE_URL/receipts/presign-download/";
  static String get SERVICE_FEE_AMOUNT =>
      "$PAYMENT_BASE_URL/service-fee-amount/";

  //TENANT REPAIRS related constants
  static String get REPAIRS_BASE_URL => "$BASE_API_URL/tenant-repairs";
  static String get TENANT_REQUEST_REPAIR =>
      "$REPAIRS_BASE_URL/tenant-request-repair/";
  static String get TENANT_ALL_REPAIRS => "$REPAIRS_BASE_URL/all-repairs/";
  static String get CARETAKER_ALL_REPAIRS =>
      "$REPAIRS_BASE_URL/caretaker-all-repairs/";
  static String get UPDATE_REPAIR_STATUS =>
      "$REPAIRS_BASE_URL/update-repair-status/";

  //MARKETPLACE related constants
  static String get MARKETPLACE_BASE_URL => "$BASE_API_URL/tenant-marketplace";
  static String get MARKETPLACE_ADD_GOODS =>
      "$MARKETPLACE_BASE_URL/add-goods/";
  static String get MARKETPLACE_PUBLISH_GOODS =>
      "$MARKETPLACE_BASE_URL/publish-goods-estate/";
  static String get MARKETPLACE_PUBLISHED_GOODS =>
      "$MARKETPLACE_BASE_URL/view-published-goods-estate/";
  static String get MARKETPLACE_ALL_GOODS =>
      "$MARKETPLACE_BASE_URL/view-all-goods-estate/";
  static String get MARKETPLACE_DELETE_GOODS =>
      "$MARKETPLACE_BASE_URL/delete-goods/";

  //NOTIFICATIONS related constants
  static String get NOTIFICATIONS_BASE_URL => "$BASE_API_URL/notifications";
  static String get MY_NOTIFICATIONS =>
      "$NOTIFICATIONS_BASE_URL/my-notifications/";
  static String get MARK_NOTIFICATION_READ =>
      "$NOTIFICATIONS_BASE_URL/mark-read/";
  static String get MARK_ALL_NOTIFICATIONS_READ =>
      "$NOTIFICATIONS_BASE_URL/mark-all-read/";
  static String get REGISTER_DEVICE =>
      "$NOTIFICATIONS_BASE_URL/register-device/";
  static String get UNREGISTER_DEVICE =>
      "$NOTIFICATIONS_BASE_URL/unregister-device/";

  //SUBSCRIPTION (SaaS tiers) related constants
  static String get SUBSCRIPTION_BASE_URL => "$BASE_API_URL/subscriptions";
  static String get SUBSCRIPTION_PLANS => "$SUBSCRIPTION_BASE_URL/plans/";
  static String get MY_SUBSCRIPTION => "$SUBSCRIPTION_BASE_URL/my-subscription/";
  static String get INITIATE_SUBSCRIPTION_PAYMENT =>
      "$SUBSCRIPTION_BASE_URL/initiate-payment/";
  static String get CHECK_SUBSCRIPTION_PAYMENT_STATUS =>
      "$SUBSCRIPTION_BASE_URL/check-payment-status/";

  //KRA eTIMS related constants (PREMIUM tier)
  static String get ETIMS_BASE_URL => "$BASE_API_URL/etims";
  static String get ETIMS_DEVICE => "$ETIMS_BASE_URL/device/";
  static String get ETIMS_DEVICE_INIT => "$ETIMS_BASE_URL/device/initialize/";
  static String get ETIMS_INVOICES => "$ETIMS_BASE_URL/invoices/";
  static String get ETIMS_INVOICE_RETRY => "$ETIMS_BASE_URL/invoices/retry/";
  static String get ETIMS_WITHHOLDING_REPORT =>
      "$ETIMS_BASE_URL/withholding-report/";

  // Account related constants
  static String get TENANTS_PROFILE => "$BASE_API_URL/auth/user-profile/";

  static String get ALL_TENANTS_URL =>
      "$BASE_API_URL/block-landlord/view-all-tenats/";

  // image url constants
  static const String SMART_NYUMBA_BLACK = "assets/images/smartnyumbablack.png";

  static const String PERSON = "assets/images/person.png";

  // Admin-related
  static String get ADMIN_LOGIN_URL =>
      "$AUTHENTICATION_BASE_URL/admin-login/";

  static String get ADMIN_FETCH_TENANTS =>
      "$BASE_API_URL/block-landlord/view-all-tenats";
  static String get ALL_PAYMENTS => "$BASE_API_URL/admin/all-tenant-payments/";
  static String get PLATFORM_EARNINGS => "$BASE_API_URL/admin/platform-earnings/";
  static String get GET_SYSTEM_CONFIG => "$BASE_API_URL/admin/system-config/";
  static String get UPDATE_SYSTEM_CONFIG => "$BASE_API_URL/admin/update-system-config/";
}
