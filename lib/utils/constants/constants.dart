import 'package:flutter/material.dart';

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
  //authentication related constants
  static const String BASE_API_URL =
      "https://api.smartnyumba.tech/apps/api/v1";
  static const String AUTHENTICATION_BASE_URL =
      "https://api.smartnyumba.tech/apps/api/v1/auth";
  static const String LOGOUT_URL =
      "https://api.smartnyumba.tech/apps/api/v1/auth/user-logout/";

  static const String ADMIN_LOGOUT_URL =
      "https://api.smartnyumba.tech/apps/api/v1/auth/admin-logout/";
  // static const String AUTHENTICATION_BASE_URL = "https://smartnyumba-production.up.railway.app/apps/api/v1/auth";
  static const String LOGIN_URL = "$AUTHENTICATION_BASE_URL/user-login/";
  static const String REGISTER_URL = "$AUTHENTICATION_BASE_URL/user-register/";
  static const String VERIFY_OTP =
      "$AUTHENTICATION_BASE_URL/user-register-verification/";
  static const String REGISTER_RESEND_OTP =
      "$AUTHENTICATION_BASE_URL/resend-otp/";
  static const String RESEND_OTP = "$AUTHENTICATION_BASE_URL/user-resend-otp/";
  static const String USER_PROFILE = "$AUTHENTICATION_BASE_URL/user-profile/";
  static const String ADMIN_PROFILE = "$AUTHENTICATION_BASE_URL/admin-profile/";

  // Landlord activation payment endpoints
  static const String INITIATE_ACTIVATION_PAYMENT =
      "$AUTHENTICATION_BASE_URL/initiate-activation-payment/";
  static const String CHECK_ACTIVATION_STATUS =
      "$AUTHENTICATION_BASE_URL/check-activation-status/";
  static const String ACTIVATION_MPESA_CALLBACK =
      "$AUTHENTICATION_BASE_URL/activation-mpesa-callback/";
  static const double LANDLORD_ACTIVATION_FEE = 500.00;

  static const String TENANT_LOGOUT_URL =
      "https://api.smartnyumba.tech/apps/api/v1/auth/user-logout/";

  //LANDLORD related constants
  static const String LANDLORD_BASE_URL =
      "https://api.smartnyumba.tech/apps/api/v1/block-landlord";
  static const String LANDLORD_LOGIN_URL =
      "$AUTHENTICATION_BASE_URL/landlord-login/";
  static const String LANDLORD_LOGOUT_URL =
      "$LANDLORD_BASE_URL/block-landlord-logout/";
  static const String LANDLORD_PROFILE_URL =
      "$LANDLORD_BASE_URL/block-landlord-profile/";
  static const String ADD_HOUSE_URL =
      "https://api.smartnyumba.tech/apps/api/v1/properties/add-block-houses/";
  static const String LANDLORD_FORGOT_PASSWORD =
      "$LANDLORD_BASE_URL/block-landlord-forgot-password/";
  static const String LANDLORD_VERIFY_CHANGE_PASSWORD =
      "$LANDLORD_BASE_URL/block-landlord-verify-change-password/";
  static const String LANDLORD_RESEND_OTP =
      "$LANDLORD_BASE_URL/block-landlord-resend-otp/";
  static const String LANDLORD_NEW_PASSWORD =
      "$LANDLORD_BASE_URL/block-landlord-new-password/";

  // Subordinate management endpoints
  static const String LANDLORD_CREATE_SUBORDINATE =
      "$AUTHENTICATION_BASE_URL/landlord-create-subordinate/";

  // Financial dashboard endpoint
  static const String LANDLORD_FINANCIAL_SUMMARY =
      "$LANDLORD_BASE_URL/financial-summary/";

  //CARETAKER related constants
  static const String CARETAKER_BASE_URL =
      "https://api.smartnyumba.tech/apps/api/v1/caretaker";
  static const String CARETAKER_LOGIN_URL =
      "$CARETAKER_BASE_URL/caretaker-login/";
  static const String CARETAKER_LOGOUT_URL =
      "$CARETAKER_BASE_URL/caretaker-logout/";
  static const String CARETAKER_PROFILE_URL =
      "$CARETAKER_BASE_URL/caretaker-profile/";
  static const String CARETAKER_FORGOT_PASSWORD =
      "$CARETAKER_BASE_URL/caretaker-forgot-password/";
  static const String CARETAKER_VERIFY_CHANGE_PASSWORD =
      "$CARETAKER_BASE_URL/caretaker-verify-change-password/";
  static const String CARETAKER_RESEND_OTP =
      "$CARETAKER_BASE_URL/caretaker-resend-otp/";
  static const String CARETAKER_NEW_PASSWORD =
      "$CARETAKER_BASE_URL/caretaker-new-password/";

  //ACCOUNTS STAFF related constants
  static const String ACCOUNTS_BASE_URL =
      "https://api.smartnyumba.tech/apps/api/v1/staff-accounts";
  static const String ACCOUNTS_LOGIN_URL = "$ACCOUNTS_BASE_URL/accounts-login/";
  static const String ACCOUNTS_LOGOUT_URL =
      "$ACCOUNTS_BASE_URL/accounts-logout/";
  static const String ACCOUNTS_PROFILE_URL =
      "$ACCOUNTS_BASE_URL/accounts-profile/";
  static const String ACCOUNTS_FORGOT_PASSWORD =
      "$ACCOUNTS_BASE_URL/accounts-forgot-password/";
  static const String ACCOUNTS_VERIFY_CHANGE_PASSWORD =
      "$ACCOUNTS_BASE_URL/accounts-verify-change-password/";
  static const String ACCOUNTS_RESEND_OTP =
      "$ACCOUNTS_BASE_URL/accounts-resend-otp/";
  static const String ACCOUNTS_NEW_PASSWORD =
      "$ACCOUNTS_BASE_URL/accounts-new-password/";

  //PAYMENT related constants
  static const String PAYMENT_BASE_URL =
      "https://api.smartnyumba.tech/apps/api/v1/tenant-services";

  static const String PAY_SERVICE = "$PAYMENT_BASE_URL/pay-service/";
  static const String PAY_RENT = "$PAYMENT_BASE_URL/pay-rent/";
  static const String MPESA_CALLBACK = "$PAYMENT_BASE_URL/mpesa-callback";
  static const String MPESA_RENT_CALLBACK =
      "$PAYMENT_BASE_URL/mpesa-rent-callback";
  static const String ALL_TRANSACTIONS = "$PAYMENT_BASE_URL/all-transactions/";
  static const String CHECK_PAYMENT_COMPLETION =
      "$PAYMENT_BASE_URL/check-subscription-status/";
  static const String CHECK_RENT_PAYMENT_COMPLETION =
      "$PAYMENT_BASE_URL/check-rent-payment-status/";
  static const String SERVICE_FEE_AMOUNT =
      "$PAYMENT_BASE_URL/service-fee-amount/";

  // Commission rate (percentage deducted from rent payments)
  static const double COMMISSION_RATE = 5.0;

  // Account related constants
  static const String TENANTS_PROFILE = "$BASE_API_URL/auth/user-profile/";

  static const String ALL_TENANTS_URL =
      "$BASE_API_URL/block-landlord/view-all-tenats/";

  // image url constants
  static const String SMART_NYUMBA_BLACK = "assets/images/smartnyumbablack.png";

  static const String PERSON = "assets/images/person.png";

  // Admin-related
  static const String ADMIN_LOGIN_URL = "$AUTHENTICATION_BASE_URL/admin-login/";

  static const String ADMIN_FETCH_TENANTS =
      "https://api.smartnyumba.tech/apps/api/v1/block-landlord/view-all-tenats";
  static const String ALL_PAYMENTS = "$BASE_API_URL/admin/all-tenant-payments/";
  static const String PLATFORM_EARNINGS = "$BASE_API_URL/admin/platform-earnings/";
  static const String GET_SYSTEM_CONFIG = "$BASE_API_URL/admin/system-config/";
  static const String UPDATE_SYSTEM_CONFIG = "$BASE_API_URL/admin/update-system-config/";
}
