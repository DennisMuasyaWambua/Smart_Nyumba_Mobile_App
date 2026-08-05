import 'dart:convert';

RentSummaryResponse rentSummaryResponseFromJson(String str) =>
    RentSummaryResponse.fromJson(json.decode(str));

String rentSummaryResponseToJson(RentSummaryResponse data) =>
    json.encode(data.toJson());

class RentSummaryResponse {
  bool status;
  RentSummaryData? data;

  RentSummaryResponse({
    required this.status,
    this.data,
  });

  factory RentSummaryResponse.fromJson(Map<String, dynamic> json) =>
      RentSummaryResponse(
        status: json["status"],
        data: json["data"] != null
            ? RentSummaryData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class RentSummaryData {
  String monthlyRent;
  PropertyInfo property;
  List<MonthlySummary> summaries;

  RentSummaryData({
    required this.monthlyRent,
    required this.property,
    required this.summaries,
  });

  factory RentSummaryData.fromJson(Map<String, dynamic> json) =>
      RentSummaryData(
        monthlyRent: json["monthly_rent"],
        property: PropertyInfo.fromJson(json["property"]),
        summaries: List<MonthlySummary>.from(
            json["summaries"].map((x) => MonthlySummary.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "monthly_rent": monthlyRent,
        "property": property.toJson(),
        "summaries": List<dynamic>.from(summaries.map((x) => x.toJson())),
      };
}

class PropertyInfo {
  String houseNumber;
  String block;

  PropertyInfo({
    required this.houseNumber,
    required this.block,
  });

  factory PropertyInfo.fromJson(Map<String, dynamic> json) => PropertyInfo(
        houseNumber: json["house_number"],
        block: json["block"],
      );

  Map<String, dynamic> toJson() => {
        "house_number": houseNumber,
        "block": block,
      };
}

class MonthlySummary {
  int month;
  int year;
  String monthName;
  String requiredAmount;
  String totalPaid;
  String balance;
  String paymentStatus; // paid, partial, unpaid
  bool isCurrentMonth;
  bool isOverdue;
  List<RentPaymentDetail> payments;

  MonthlySummary({
    required this.month,
    required this.year,
    required this.monthName,
    required this.requiredAmount,
    required this.totalPaid,
    required this.balance,
    required this.paymentStatus,
    required this.isCurrentMonth,
    required this.isOverdue,
    required this.payments,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) => MonthlySummary(
        month: json["month"],
        year: json["year"],
        monthName: json["month_name"],
        requiredAmount: json["required_amount"],
        totalPaid: json["total_paid"],
        balance: json["balance"],
        paymentStatus: json["payment_status"],
        isCurrentMonth: json["is_current_month"],
        isOverdue: json["is_overdue"],
        payments: List<RentPaymentDetail>.from(
            json["payments"].map((x) => RentPaymentDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "month": month,
        "year": year,
        "month_name": monthName,
        "required_amount": requiredAmount,
        "total_paid": totalPaid,
        "balance": balance,
        "payment_status": paymentStatus,
        "is_current_month": isCurrentMonth,
        "is_overdue": isOverdue,
        "payments": List<dynamic>.from(payments.map((x) => x.toJson())),
      };
}

class RentPaymentDetail {
  int id;
  String amount;
  int status; // 0=pending, 1=completed, 2=failed
  String paymentMode;
  DateTime createdAt;

  RentPaymentDetail({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMode,
    required this.createdAt,
  });

  factory RentPaymentDetail.fromJson(Map<String, dynamic> json) =>
      RentPaymentDetail(
        id: json["id"],
        amount: json["amount"],
        status: json["status"],
        paymentMode: json["payment_mode"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "status": status,
        "payment_mode": paymentMode,
        "created_at": createdAt.toIso8601String(),
      };
}
