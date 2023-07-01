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
  static const String payment = "Make Payment";
  static const String welcomeMsg = "Welcome";
  static const String paymentHistory = "Payment Statement";
  static const String serviceChargeBalance = "Service Charge Balance";
  static const String payServiceCharge = "Pay Service Charge";
  static const String service = "Request for Repairs";
  static const String marketPlace = "Marketplace";
  static const String noService = "You are not subscribed to any service";
  static const String serviceCharge = "Service Charge";
  static const String OtpVerification = "OTP VERIFICATION";
  static const String didntGetCode = "Didn't get code? Resend Code";

  //colors
  static const buttonColor = Color(0xffbc9f6d);
  static const serviceColor = Color(0xfff68070);
  static const paymentColor = Color(0xff4cd964);
  static const servicesColor = Color(0xff567df4);
  static const purple = Color(0xff6246ea);

  // URL constants

  //authentication related constants
  static const String BASE_API_URL = "https://smartnyumba.com/apps/user/api/v1";
  static const String AUTHENTICATION_BASE_URL =
      "https://smartnyumba.com/apps/user/api/v1/auth";
  static const String LOGIN_URL = "$AUTHENTICATION_BASE_URL/user-login/";
  static const String REGISTER_URL = "$AUTHENTICATION_BASE_URL/user-register/";
  static const String VERIFY_OTP =
      "$AUTHENTICATION_BASE_URL/user-register-verification/";

  static const String RESEND_OTP = "$AUTHENTICATION_BASE_URL/user-resend-otp/";

  //PAYMENT related constants
  static const String PAYMENT_BASE_URL =
      "https://smartnyumba.com/apps/user/api/v1/services";
  static const String PAY_SERVICE = "$PAYMENT_BASE_URL/pay-service/";
  static const String MPESA_CALLBACK = "$PAYMENT_BASE_URL/mpesa-callback";
  static const String ALL_TRANSITIONS = "$PAYMENT_BASE_URL/all-transactions/";
  static const String CHECK_PAYMENT_COMPLETION =
      "$PAYMENT_BASE_URL/check-subscription-status";

  // Account related constants
  static const String TENANTS_PROFILE = "$BASE_API_URL/auth/user-profile/";
}
