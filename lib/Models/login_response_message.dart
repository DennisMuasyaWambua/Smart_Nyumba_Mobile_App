// To parse this JSON data, do
//
//     final loginResponseMessage = loginResponseMessageFromJson(jsonString);

import 'dart:convert';

// LoginResponseMessage loginResponseMessageFromJson(String str) => LoginResponseMessage.fromJson(json.decode(str));

String loginResponseMessageToJson(LoginResponseMessage data) => json.encode(data.toJson());

class LoginResponseMessage {
  LoginResponseMessage({
    required this.status,
    required this.message,
    this.accessToken,
    this.expiresIn,
    this.tokenType,
  });

  bool status;
  String message;
  String?accessToken;
  String?expiresIn;
  String?tokenType;

  factory LoginResponseMessage.fromJson(Map<String, dynamic> json) => LoginResponseMessage(
    status: json["status"],
    message: json["message"],
    accessToken: json["access_token"],
    expiresIn: json["expires_in"],
    tokenType: json["token_type"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "access_token": accessToken,
    "expires_in": expiresIn,
    "token_type": tokenType,
  };
}

