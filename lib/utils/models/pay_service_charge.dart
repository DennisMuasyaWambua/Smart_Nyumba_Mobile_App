// To parse this JSON data, do
//
//     final payServiceCharge = payServiceChargeFromJson(jsonString);

import 'dart:convert';

PayServiceCharge payServiceChargeFromJson(String str) => PayServiceCharge.fromJson(json.decode(str));

String payServiceChargeToJson(PayServiceCharge data) => json.encode(data.toJson());

class PayServiceCharge {
    bool status;
    String message;

    PayServiceCharge({
        required this.status,
        required this.message,
    });

    factory PayServiceCharge.fromJson(Map<String, dynamic> json) => PayServiceCharge(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
