class ActivationPaymentResponse {
  bool? status;
  String? message;
  String? merchantRequestID;
  String? checkoutRequestID;

  // Pesapal fields
  dynamic data;  // Can contain redirect_url, order_tracking_id, etc.
  String? redirectUrl;
  String? orderTrackingId;

  ActivationPaymentResponse({
    this.status,
    this.message,
    this.merchantRequestID,
    this.checkoutRequestID,
    this.data,
    this.redirectUrl,
    this.orderTrackingId,
  });

  ActivationPaymentResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    // M-Pesa fields
    merchantRequestID = json['MerchantRequestID'];
    checkoutRequestID = json['CheckoutRequestID'];

    // Pesapal fields
    redirectUrl = json['redirect_url'];
    orderTrackingId = json['order_tracking_id'];

    // Generic data field (can be used for any payment gateway)
    // Store the full response for flexibility
    if (json.containsKey('redirect_url') || json.containsKey('order_tracking_id')) {
      data = {
        'redirect_url': json['redirect_url'],
        'order_tracking_id': json['order_tracking_id'],
        'merchant_reference': json['merchant_reference'],
        'amount': json['amount'],
      };
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['MerchantRequestID'] = merchantRequestID;
    data['CheckoutRequestID'] = checkoutRequestID;
    data['redirect_url'] = redirectUrl;
    data['order_tracking_id'] = orderTrackingId;
    if (this.data != null) {
      data['data'] = this.data;
    }
    return data;
  }
}
