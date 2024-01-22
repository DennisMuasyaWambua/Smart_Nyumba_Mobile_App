// To parse this JSON data, do
//
//     final amount = amountFromJson(jsonString);

import 'dart:convert';

Amount amountFromJson(String str) => Amount.fromJson(json.decode(str));

String amountToJson(Amount data) => json.encode(data.toJson());

class Amount {
  bool status;
  double amount;

  Amount({
    required this.status,
    required this.amount,
  });

  factory Amount.fromJson(Map<String, dynamic> json) => Amount(
    status: json["status"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "amount": amount,
  };
}
