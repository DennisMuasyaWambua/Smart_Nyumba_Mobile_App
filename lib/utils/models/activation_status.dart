class ActivationStatus {
  bool? status;
  String? message;
  int? activationStatus; // 0=pending, 1=completed, 2=failed
  String? activationFee;
  DateTime? paymentDate;

  ActivationStatus({
    this.status,
    this.message,
    this.activationStatus,
    this.activationFee,
    this.paymentDate,
  });

  ActivationStatus.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    activationStatus = json['activation_status'];
    activationFee = json['activation_fee'];
    if (json['payment_date'] != null) {
      paymentDate = DateTime.parse(json['payment_date']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['activation_status'] = activationStatus;
    data['activation_fee'] = activationFee;
    if (paymentDate != null) {
      data['payment_date'] = paymentDate!.toIso8601String();
    }
    return data;
  }
}
