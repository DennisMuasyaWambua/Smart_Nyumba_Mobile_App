import 'dart:convert';

SendOtp sendOtpFromJson(String str) => SendOtp.fromJson(json.decode(str));

String sendOtpToJson(SendOtp data) => json.encode(data.toJson());

class SendOtp {
    bool status;
    String message;

    SendOtp({
        required this.status,
        required this.message,
    });

    factory SendOtp.fromJson(Map<String, dynamic> json) => SendOtp(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
