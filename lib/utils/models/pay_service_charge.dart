// To parse this JSON data, do
//
//     final payServiceCharge = payServiceChargeFromJson(jsonString);

import 'dart:convert';

PayServiceCharge payServiceChargeFromJson(String str) => PayServiceCharge.fromJson(json.decode(str));

String payServiceChargeToJson(PayServiceCharge data) => json.encode(data.toJson());

class PayServiceCharge {
    bool status;
    String message;
    String? redirectUrl;
    String? orderTrackingId;
    int? transactionId;

    PayServiceCharge({
        required this.status,
        required this.message,
        this.redirectUrl,
        this.orderTrackingId,
        this.transactionId,
    });

    factory PayServiceCharge.fromJson(Map<String, dynamic> json) => PayServiceCharge(
        status: json["status"],
        message: json["message"],
        redirectUrl: json["redirect_url"],
        orderTrackingId: json["order_tracking_id"],
        transactionId: json["transaction_id"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "redirect_url": redirectUrl,
        "order_tracking_id": orderTrackingId,
        "transaction_id": transactionId,
    };
}
