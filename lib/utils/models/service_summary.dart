// Mirrors rent_summary.dart. The backend `monthly-service-summary` endpoint
// returns the same shape as `monthly-rent-summary` (see
// tenant_services/service_summary_view.py) so the statement UI can be shared.

import 'dart:convert';

ServiceSummaryResponse serviceSummaryResponseFromJson(String str) =>
    ServiceSummaryResponse.fromJson(json.decode(str));

class ServiceSummaryResponse {
  bool status;
  ServiceSummaryData? data;

  ServiceSummaryResponse({required this.status, this.data});

  factory ServiceSummaryResponse.fromJson(Map<String, dynamic> json) =>
      ServiceSummaryResponse(
        status: json["status"] ?? false,
        data: json["data"] != null
            ? ServiceSummaryData.fromJson(json["data"])
            : null,
      );
}

class ServiceSummaryData {
  String monthlyService;
  ServiceProperty property;
  List<ServiceMonthlySummary> summaries;

  ServiceSummaryData({
    required this.monthlyService,
    required this.property,
    required this.summaries,
  });

  factory ServiceSummaryData.fromJson(Map<String, dynamic> json) =>
      ServiceSummaryData(
        monthlyService: json["monthly_service"].toString(),
        property: ServiceProperty.fromJson(json["property"]),
        summaries: List<ServiceMonthlySummary>.from(
            json["summaries"].map((x) => ServiceMonthlySummary.fromJson(x))),
      );
}

class ServiceProperty {
  String houseNumber;
  String block;

  ServiceProperty({required this.houseNumber, required this.block});

  factory ServiceProperty.fromJson(Map<String, dynamic> json) =>
      ServiceProperty(
        houseNumber: json["house_number"].toString(),
        block: json["block"].toString(),
      );
}

class ServiceMonthlySummary {
  int month;
  int year;
  String monthName;
  String requiredAmount;
  String totalPaid;
  String balance;
  String paymentStatus; // paid, partial, unpaid
  bool isCurrentMonth;
  bool isOverdue;
  List<ServicePaymentDetail> payments;

  ServiceMonthlySummary({
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

  factory ServiceMonthlySummary.fromJson(Map<String, dynamic> json) =>
      ServiceMonthlySummary(
        month: json["month"],
        year: json["year"],
        monthName: json["month_name"],
        requiredAmount: json["required_amount"].toString(),
        totalPaid: json["total_paid"].toString(),
        balance: json["balance"].toString(),
        paymentStatus: json["payment_status"],
        isCurrentMonth: json["is_current_month"] ?? false,
        isOverdue: json["is_overdue"] ?? false,
        payments: List<ServicePaymentDetail>.from(
            (json["payments"] ?? []).map((x) => ServicePaymentDetail.fromJson(x))),
      );
}

class ServicePaymentDetail {
  int id;
  String amount;
  int status; // 1=completed
  String paymentMode;
  String confirmationCode;
  DateTime? createdAt;

  ServicePaymentDetail({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMode,
    required this.confirmationCode,
    this.createdAt,
  });

  factory ServicePaymentDetail.fromJson(Map<String, dynamic> json) =>
      ServicePaymentDetail(
        id: json["id"],
        amount: json["amount"].toString(),
        status: json["status"] ?? 0,
        paymentMode: (json["payment_mode"] ?? "pesapal").toString(),
        confirmationCode: (json["confirmation_code"] ?? "").toString(),
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
      );
}
