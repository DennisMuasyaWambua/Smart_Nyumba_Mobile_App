// To parse this JSON data, do
//
//     final allTransactions = allTransactionsFromJson(jsonString);

import 'dart:convert';

AllTransactions allTransactionsFromJson(String str) => AllTransactions.fromJson(json.decode(str));

String allTransactionsToJson(AllTransactions data) => json.encode(data.toJson());

class AllTransactions {
    bool status;
    List<Transaction> transactions;

    AllTransactions({
        required this.status,
        required this.transactions,
    });

    factory AllTransactions.fromJson(Map<String, dynamic> json) => AllTransactions(
        status: json["status"],
        transactions: List<Transaction>.from(json["transactions"].map((x) => Transaction.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "transactions": List<dynamic>.from(transactions.map((x) => x.toJson())),
    };
}

class Transaction {
    int id;
    User user;
    ServiceName serviceName;
    String amount;
    PaymentMode paymentMode;
    String annualServiceCharge;
    int status;
    DateTime datePaid;
    String merchantRequestId;
    String checkoutRequestId;
    String houseNumber;
    BlockNumber blockNumber;

    Transaction({
        required this.id,
        required this.user,
        required this.serviceName,
        required this.amount,
        required this.paymentMode,
        required this.annualServiceCharge,
        required this.status,
        required this.datePaid,
        required this.merchantRequestId,
        required this.checkoutRequestId,
        required this.houseNumber,
        required this.blockNumber,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        user: User.fromJson(json["user"]),
        serviceName: serviceNameValues.map[json["service_name"]]!,
        amount: json["amount"],
        paymentMode: paymentModeValues.map[json["payment_mode"]]!,
        annualServiceCharge: json["annual_service_charge"],
        status: json["status"],
        datePaid: DateTime.parse(json["date_paid"]),
        merchantRequestId: json["MerchantRequestID"],
        checkoutRequestId: json["CheckoutRequestID"],
        houseNumber: json["house_number"],
        blockNumber: blockNumberValues.map[json["block_number"]]!,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "service_name": serviceNameValues.reverse[serviceName],
        "amount": amount,
        "payment_mode": paymentModeValues.reverse[paymentMode],
        "annual_service_charge": annualServiceCharge,
        "status": status,
        "date_paid": "${datePaid.year.toString().padLeft(4, '0')}-${datePaid.month.toString().padLeft(2, '0')}-${datePaid.day.toString().padLeft(2, '0')}",
        "MerchantRequestID": merchantRequestId,
        "CheckoutRequestID": checkoutRequestId,
        "house_number": houseNumber,
        "block_number": blockNumberValues.reverse[blockNumber],
    };
}

enum BlockNumber {
    A1
}

final blockNumberValues = EnumValues({
    "A1": BlockNumber.A1
});

enum PaymentMode {
    MPESA
}

final paymentModeValues = EnumValues({
    "mpesa": PaymentMode.MPESA
});

enum ServiceName {
    SERVICE_CHARGE
}

final serviceNameValues = EnumValues({
    "Service charge": ServiceName.SERVICE_CHARGE
});

class User {
    List<Tenant> tenant;
    Email email;
    Email username;
    int role;
    String mobileNumber;
    int status;

    User({
        required this.tenant,
        required this.email,
        required this.username,
        required this.role,
        required this.mobileNumber,
        required this.status,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        tenant: List<Tenant>.from(json["tenant"].map((x) => Tenant.fromJson(x))),
        email: emailValues.map[json["email"]]!,
        username: emailValues.map[json["username"]]!,
        role: json["role"],
        mobileNumber: json["mobile_number"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "tenant": List<dynamic>.from(tenant.map((x) => x.toJson())),
        "email": emailValues.reverse[email],
        "username": emailValues.reverse[username],
        "role": role,
        "mobile_number": mobileNumber,
        "status": status,
    };
}

enum Email {
    DENNIS_WAMBUA_STRATHMORE_EDU
}

final emailValues = EnumValues({
    "dennis.wambua@strathmore.edu": Email.DENNIS_WAMBUA_STRATHMORE_EDU
});

class Tenant {
    PropertyBlock propertyBlock;

    Tenant({
        required this.propertyBlock,
    });

    factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        propertyBlock: PropertyBlock.fromJson(json["PropertyBlock"]),
    );

    Map<String, dynamic> toJson() => {
        "PropertyBlock": propertyBlock.toJson(),
    };
}

class PropertyBlock {
    String houseNumber;
    Block block;

    PropertyBlock({
        required this.houseNumber,
        required this.block,
    });

    factory PropertyBlock.fromJson(Map<String, dynamic> json) => PropertyBlock(
        houseNumber: json["house_number"],
        block: Block.fromJson(json["block"]),
    );

    Map<String, dynamic> toJson() => {
        "house_number": houseNumber,
        "block": block.toJson(),
    };
}

class Block {
    BlockNumber blockNumber;

    Block({
        required this.blockNumber,
    });

    factory Block.fromJson(Map<String, dynamic> json) => Block(
        blockNumber: blockNumberValues.map[json["block_number"]]!,
    );

    Map<String, dynamic> toJson() => {
        "block_number": blockNumberValues.reverse[blockNumber],
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
