class MySubscription {
  final String? tierLevel;
  final String status;
  final bool isActive;
  final bool isPremium;
  final int? unitLimit;
  final String? startDate;
  final String? expiryDate;

  MySubscription({
    this.tierLevel,
    required this.status,
    required this.isActive,
    required this.isPremium,
    this.unitLimit,
    this.startDate,
    this.expiryDate,
  });

  factory MySubscription.fromJson(Map<String, dynamic> json) {
    return MySubscription(
      tierLevel: json['tier_level'],
      status: json['status'] ?? 'INACTIVE',
      isActive: json['is_active'] ?? false,
      isPremium: json['is_premium'] ?? false,
      unitLimit: json['unit_limit'],
      startDate: json['start_date'],
      expiryDate: json['expiry_date'],
    );
  }
}

class SubscriptionPlan {
  final String tier;
  final String name;
  final String price;
  final int unitLimit;
  final List<String> features;

  SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.price,
    required this.unitLimit,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      tier: json['tier'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '0',
      unitLimit: json['unit_limit'] ?? 0,
      features: (json['features'] as List<dynamic>? ?? [])
          .map((f) => f.toString())
          .toList(),
    );
  }
}

class SubscriptionPaymentInit {
  final bool status;
  final String message;
  final String? paymentUrl;
  final String? orderId;
  final String? amount;

  SubscriptionPaymentInit({
    required this.status,
    required this.message,
    this.paymentUrl,
    this.orderId,
    this.amount,
  });

  factory SubscriptionPaymentInit.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentInit(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      paymentUrl: json['payment_url'],
      orderId: json['order_id'],
      amount: json['amount'],
    );
  }
}

class EtimsDevice {
  final String? deviceSerial;
  final String? branchId;
  final String? kraPin;
  final String? sdcId;
  final String? taxMapping;
  final String status;

  EtimsDevice({
    this.deviceSerial,
    this.branchId,
    this.kraPin,
    this.sdcId,
    this.taxMapping,
    required this.status,
  });

  factory EtimsDevice.fromJson(Map<String, dynamic> json) {
    return EtimsDevice(
      deviceSerial: json['device_serial'],
      branchId: json['branch_id'],
      kraPin: json['kra_pin'],
      sdcId: json['sdc_id'],
      taxMapping: json['tax_mapping'],
      status: json['status'] ?? 'PENDING',
    );
  }
}

class EtimsInvoice {
  final int rentPaymentId;
  final String? tenantEmail;
  final String amount;
  final int month;
  final int year;
  final String syncStatus;
  final String? kraInvoiceNumber;
  final String? kraQrCodeUrl;

  EtimsInvoice({
    required this.rentPaymentId,
    this.tenantEmail,
    required this.amount,
    required this.month,
    required this.year,
    required this.syncStatus,
    this.kraInvoiceNumber,
    this.kraQrCodeUrl,
  });

  factory EtimsInvoice.fromJson(Map<String, dynamic> json) {
    return EtimsInvoice(
      rentPaymentId: json['rent_payment_id'] ?? 0,
      tenantEmail: json['tenant_email'],
      amount: json['amount'] ?? '0',
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      syncStatus: json['sync_status'] ?? 'PENDING',
      kraInvoiceNumber: json['kra_invoice_number'],
      kraQrCodeUrl: json['kra_qr_code_url'],
    );
  }
}
