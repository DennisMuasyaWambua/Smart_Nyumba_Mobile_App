// To parse this JSON data, do
//
//     final allTransactions = allTransactionsFromJson(jsonString);

import 'dart:convert';

AllTransactions allTransactionsFromJson(String str) => AllTransactions.fromJson(json.decode(str));

String allTransactionsToJson(AllTransactions data) => json.encode(data.toJson());

class AllTransactions {
    bool? status;
    List<Transaction>? transactions;

    AllTransactions({
        this.status,
        this.transactions,
    });

    factory AllTransactions.fromJson(Map<String, dynamic> json) => AllTransactions(
        status: json["status"],
        transactions: json["transactions"] == null ? [] : List<Transaction>.from(json["transactions"]!.map((x) => Transaction.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "transactions": transactions == null ? [] : List<dynamic>.from(transactions!.map((x) => x.toJson())),
    };
}

class Transaction {
    int? id;
    String? serviceName;
    String? amount;
    String? paymentMode;
    int? status;
    DateTime? datePaid;
    String? merchantRequestId;
    String? checkoutRequestId;
    int? user;

    Transaction({
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

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
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
