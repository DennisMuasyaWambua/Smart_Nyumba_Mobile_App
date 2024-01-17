// To parse this JSON data, do
//
//     final checkPaymentStatus = checkPaymentStatusFromJson(jsonString);

import 'dart:convert';

CheckPaymentStatus checkPaymentStatusFromJson(String str) => CheckPaymentStatus.fromJson(json.decode(str));

String checkPaymentStatusToJson(CheckPaymentStatus data) => json.encode(data.toJson());

class CheckPaymentStatus {
    bool? status;
    String? message;
    Data? data;

    CheckPaymentStatus({
        this.status,
        this.message,
        this.data,
    });

    factory CheckPaymentStatus.fromJson(Map<String, dynamic> json) => CheckPaymentStatus(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    int? id;
    String? serviceName;
    String? amount;
    String? paymentMode;
    int? status;
    DateTime? datePaid;
    String? merchantRequestId;
    String? checkoutRequestId;
    int? user;

    Data({
        this.id,
        this.serviceName,
        this.amount,
        this.paymentMode,
        this.status,
        this.datePaid,
        this.merchantRequestId,
        this.checkoutRequestId,
        this.user,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        serviceName: json["service_name"],
        amount: json["amount"],
        paymentMode: json["payment_mode"],
        status: json["status"],
        datePaid: json["date_paid"] == null ? null : DateTime.parse(json["date_paid"]),
        merchantRequestId: json["MerchantRequestID"],
        checkoutRequestId: json["CheckoutRequestID"],
        user: json["user"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "service_name": serviceName,
        "amount": amount,
        "payment_mode": paymentMode,
        "status": status,
        "date_paid": "${datePaid!.year.toString().padLeft(4, '0')}-${datePaid!.month.toString().padLeft(2, '0')}-${datePaid!.day.toString().padLeft(2, '0')}",
        "MerchantRequestID": merchantRequestId,
        "CheckoutRequestID": checkoutRequestId,
        "user": user,
    };
}
